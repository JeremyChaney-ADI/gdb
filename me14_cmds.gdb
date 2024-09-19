#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME14 Area
#***************************************************************************
#***************************************************************************
#***************************************************************************

define unlock_otp
    # First, put flash controller in known lock state.
    lock_otp
    # Write acntl to unlock OTP
    set *$fctl_acntl=0x3a7f5ca3
    set *$fctl_acntl=0xa1e34f20
    set *$fctl_acntl=0x9608b2c1
end

define me14_otp_smartdump
    print "ME14 Info Block Dump"
    set variable $base=0x10800000
    unlock_otp
    print "Base Address: $base"
    print "USN"
    x/6x $base+0x0
    print "FMV"
    x/2x $base+0x18
    print "FTM"
    x/2x $base+0x20
    print "TM"
    x/2x $base+0x28
    print "ICE Lock"
    x/4x $base+0x30
    print "LCP#5 Pattern 1"
    x/4x $base+0x40
    print "LCP#5 Pattern 2"
    x/4x $base+0x50
    print "Partial CRK1 Dump"
    x/20x $base+0x1000
    print "Partial CRK2 Dump"
    x/20x $base+0x14b0
    print "SCP GPIO Stimulus 1"
    x/4x $base+0x70
    print "SCP GPIO Stimulus 2"
    x/4x $base+0x80
    print "SCP GPIO Stimulus 3"
    x/4x $base+0x90
    print "Digital Key ID"
    x/4x $base+0xa0
    print "Override HIRC Frequency"
    x/4x $base+0xb0
    print "Override HIRC8 Frequency"
    x/4x $base+0xc0
    print "Override HIRC96 Frequency"
    x/4x $base+0xd0
    print "ROM Code Checksum Enable"
    x/4x $base+0x100
    print "TPU Check/ROM Enable"
    x/4x $base+0x300
    print "Binary Location"
    x/4x $base+0x1970
    print "CLKCN_WRITE_0"
    x/4x $base+0x19a0
    lock_otp
end
document me14_otp_smartdump
    Dump known areas of ME14 Information Block
end

define me14_run_rom_without_otp
    tbreak main.c:104
    c
    set result=0
    tbreak set_system_frequency
    c
    # Set to DIV1 mode (running on HIRC) to make USB IP work (AHB must be > UTMI_CLK)
    set MXC_GCR->clkcn=0x6404a008
    finish
    tbreak lcm_public.c:87
    c
    set result=0
    tbreak lcm_public.c:99
    c
    set result=0
    tbreak lcm_public.c:116
    c
    set result=0
    step
    step
    set result=0
    step
    step
    set result=0
    tbreak lcm_public.c:154
    c
    set result=0
    # Flow with no stimulus pattern set in Info Block/OTP
    tbreak pm_scp.c:139
    c
    set pm_context.scp.boot.stimulus[pm_context.scp.boot.active_index].port = N_BM_BUS_USB
    set pm_context.scp.boot.stimulus[pm_context.scp.boot.active_index].conf[0] = N_BM_BUS_USB
    tbreak usb_init
    c
    # Flow for use with enter bootloader with stimulus
    # tbreak pm_tools.c:730
    # c
    # set pm_context.scp.boot.stimulus[pm_context.scp.boot.active_index].port = N_BM_BUS_USB
    # set pm_context.scp.boot.stimulus[pm_context.scp.boot.active_index].conf[0] = N_BM_BUS_USB
    # tbreak usb_init
    # c
end
document me14_run_rom_without_otp
    Run through ROM and get to SCP USB without writing any OTP values.
    ME14 are in short supply right now and I am avoiding any OTP writes.
end

define me14_write_rom_basics
    unlock_otp
    # Write USN
    write_flash_128 0x00080000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    write_flash_128 0x00080010 0x00570000 0x00000000 0xffffffff 0xffffffff
    # Write FTM
    write_flash_128 0x00080020 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff
    # Write LCP5 Pattern #1
    write_flash_128 0x00080040 0x00001246 0x59455305 0x00000000 0x80000000
    # Write LCP5 Pattern #2
    write_flash_128 0x00080050 0x00001246 0x59455305 0x00000000 0x80000000
    # ROM Checksum Enable
    #  write_flash_128 0x00080100 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff
    # Write HIRC Override Word (set to 40MHz) (offset 0xB0)
    #  write_flash_128 0x000800B0 0x2d00229f 0x00000131 0x00000000 0x00000000
    # Write HIRC Override Word (set to 80MHz) (offset 0xB0)
    write_flash_128 0x000800B0 0x5a007cc5 0x00000262 0x00000000 0x00000000
    x/100x 0x10800000
    lock_otp
end
document me14_write_rom_basics
    ME14 Write USN and other stuff test writes in during production
end

define me14_write_enable_secure_rom
    unlock_otp
    write_flash_128 0x00080300 0xffffffff 0xffffff5a 0xffffffff 0xffffffff
    x/100x 0x10800000
    lock_otp
end
document me14_write_enable_secure_rom
    ME14 Enable secure ROM to run (this ROM enable functionality is called enable TPU by the ROM code)
end

define me14_write_enable_usb_p17_stim1
    unlock_otp
    write_flash_128 0x00080070 0x0123926f 0x00000000 0x00000000 0x00000000 
    x/4x 0x10800070
    lock_otp
end
document me14_write_enable_usb_p17_stim1
    ME14 Set USB on P1.7 low stimulus location 1.
end

define me14_write_enable_usb_p00_stim1
    unlock_otp
    write_flash_128 0x00080070 0x01003aaf 0x00000000 0x00000000 0x00000000 
    # Use P2.7 low instead
    #write_flash_128 0x00080070 0x0143c66d 0x00000000 0x00000000 0x00000000 
    x/100x 0x10800000
    lock_otp
end
document me14_write_enable_usb_p00_stim1
    ME14 Set USB on P0.0 low stimulus location 1.
end

define me14_write_clkcn0_otp_value
    unlock_otp
    # Write CLKCN_WRITE_0_VALUE at 0x19a0 to 0x6404a008
    write_flash_128 0x000819a0 0x50040b6b 0x00003202 0x00000000 0x00000000
    x/4x 0x108019a0
    lock_otp
end
document me14_write_clkcn0_otp_value
    ME14 Write CLKCN 0 Value
end

define me14_write_dev_crk
    # Development CRK signed with ME14 production MRK (with crk signature at 0x1260)
    unlock_otp

    # Write digital key offset
    write_flash_128 0x100800a0 0x9e1e0791 0x000061e1 0x00000000 0x00000000

    # Development CRK (ECDSA256)
    write_flash_128 0x10081000 0x11d4296f 0x243cc2e4 0x1d47b46e 0x797b799f
    write_flash_128 0x10081010 0x52903f65 0x162e780a 0xc6778e36 0x78c697cf
    write_flash_128 0x10081020 0xe78e8c5a 0x709da100 0xddce3092 0x42f4a8f5
    write_flash_128 0x10081030 0x47193bc7 0x10e999c7 0x310cef65 0x21ede046
    write_flash_128 0x10081040 0xa5183b4b 0x6df913bd 0x00007f47 0x00000000
    write_flash_128 0x10081050 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081060 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081070 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081080 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081090 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100810a0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100810b0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100810c0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100810d0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100810e0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100810f0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081100 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081110 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081120 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081130 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081140 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081150 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081160 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081170 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081180 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081190 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100811a0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100811b0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100811c0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100811d0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100811e0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100811f0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081200 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081210 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081220 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081230 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081240 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081250 0x00001715 0x00000000 0x00000000 0x00000000

    # CRK Signature
    write_flash_128 0x10081260 0x286cf5cd 0xd46fcf5e 0xc2527dd7 0x32b1334e
    write_flash_128 0x10081270 0xe23b0c34 0x7cdb2bb2 0xd121b94b 0x36258797
    write_flash_128 0x10081280 0x4d736c12 0x7cf4248b 0x18555fc6 0x4ce20b3f
    write_flash_128 0x10081290 0x139b7b5f 0x3e8e685c 0xaf8c5bf1 0x4cf1b041
    write_flash_128 0x100812a0 0x6af405ca 0x38cad331 0x0000355a 0x00000000
    write_flash_128 0x100812b0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100812c0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100812d0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100812e0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100812f0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081300 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081310 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081320 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081330 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081340 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081350 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081360 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081370 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081380 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081390 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100813a0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100813b0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100813c0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100813d0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100813e0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100813f0 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081400 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081410 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081420 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081430 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081440 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081450 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081460 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081470 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081480 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x10081490 0x00001715 0x00000000 0x00000000 0x00000000
    write_flash_128 0x100814a0 0x00001715 0x00000000 0x00000000 0x00000000

    lock_otp
end

define me14_write_stim1_uart_p0_18_low_broken
    unlock_otp
    write_flash_128 0x00080070 0x0089135f 0x00000000 0x00000000 0x00000000
    lock_otp
end
document me14_write_stim1_uart_p0_18_low_broken
    ME14 Write BROKEN!! STIM1 Value for UART active on P0.18 low
    Customer wrote zeros in the UART "conf" data so UART init fails.
    Can recover this problem with me14_write_stim2_uart_p0_18_low
end

define me14_write_stim1_uart_p0_18_low
    unlock_otp
    write_flash_128 0x00080070 0x00897205 0x03840180 0x00000000 0x00000000
    lock_otp
end
document me14_write_stim1_uart_p0_18_low
    ME14 Write STIM1 Value for UART active on P0.18 low
end

define me14_write_stim2_uart_p0_18_low
    unlock_otp
    write_flash_128 0x00080080 0x00897205 0x03840180 0x00000000 0x00000000
    lock_otp
end
document me14_write_stim2_uart_p0_18_low
    ME14 Write STIM2 Value for UART active on P0.18 low
end