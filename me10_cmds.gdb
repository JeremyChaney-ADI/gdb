#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME10 Area
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

define secure_device_otp_smartdump
 print "Base Address: $arg0"
 print "USN"
 x/6x $arg0+0x0
 print "FMV"
 x/2x $arg0+0x18
 print "FTM"
 x/2x $arg0+0x20
 print "TM"
 x/2x $arg0+0x28
 print "ICE Lock"
 x/2x $arg0+0x30
 print "LCP#5 Pattern 1"
 x/2x $arg0+0x40
 print "LCP#5 Pattern 2"
 x/2x $arg0+0x48
 print "Partial CRK Dump"
 x/8x $arg0+0x1000
end
document secure_device_otp_smartdump
    Dump known areas of Secure Device Information Block
    This should work on the following devices which use 32-bit
    wide flash word size.  ME14 and others use 128-bit word
    and the mapping has changed.
    ME10, ES06, ES08, MQ55
end

define me10_otp_dump
    unlock_otp
    x/64x 0x10800000
    x/64x 0x10804000
    lock_otp
end

define me10_force_usb_bootloader_path
    set $i=0
    mrh
    b pm_scp.c:141
    c
    while (1)
        printf "Sleeping 2 seconds\n"
        shell sleep 2
        set $i=$i+1
        printf "Count %d\n",$i
        set pm_context.scp.boot.stimulus.usage=2
        c
    end
end

define me10_otp_smartdump
    print "ME10 Info Block Dump"
    set variable $base=0x10800000
    unlock_otp
    secure_device_otp_smartdump $base
    print "SCP GPIO Stimulus"
    x/2x $base+0x50
    print "Override HIRC Frequency"
    x/2x $base+0x68
    print "Override HIRC8 Frequency"
    x/2x $base+0x70
    print "Override HIRC96 Frequency"
    x/2x $base+0x78
    print "ROM Code Checksum Enable"
    x/2x $base+0x100
    print "TPU Check (A1 silicon, collides with BB-SIR5 trim)"
    x/2x $base+0x200
    print "TPU Check (A2 silicon)"
    x/2x $base+0x300
    print "Application Versions (A2 silicon)"
    x/12x $base+0x310
    print "Patch Address"
    x/2x $base+0x340
    lock_otp
end
document me10_otp_smartdump
    Dump known areas of ME10 Information Block
end

define me10_otp_dumpcrk
    print "ME10 Info Block CRK Dump"
    set variable $base=0x10800000
    unlock_otp

    print "CRK"
    x/172x $base+0x1000
    print "CRK Key Length, exponent, exponent length"
    x/1x $base+0x12b0
    x/1x $base+0x12b4
    print "CRK Signature" 
    x/1x $base+0x12b8
    x/1x $base+0x12bc
    x/168x $base+0x12c0
    x/1x $base+0x1560
    x/1x $base+0x1564

    lock_otp
end

# ME10 Enable USB bootloader on P2.7=1
define me10_write_usb_enable_on2p7_otp
    unlock_otp
    write_flash 0x10800050 0xd3ff8f10
    write_flash 0x10800054 0x7fffffff
    x/2x 0x10800050
    lock_otp
end

# ME10 Enable UART bootloader on P2.7=1
define me10_write_uart_enable_on2p7_otp
    unlock_otp
    write_flash 0x10800050 0xffd3b561
    write_flash 0x10800054 0x7fffffff
    x/2x 0x10800050
    lock_otp
end

# ME10 Enable USB bootloader on P1.0=0
define me10_write_usb_enable_on1p0_low_otp
    unlock_otp
    write_flash 0x10800050 0xa07f9f09
    write_flash 0x10800054 0x7fffffff
    x/2x 0x10800050
    lock_otp
end


# ME10 Set HIRC96 frequency to 80MHz (for emulator at 40 MHz with PSC set to DIV2)
define me10_write_HIRC96_override_80Mhz
    unlock_otp
    write_flash 0x10800078 0x5a007cc5
    write_flash 0x1080007c 0x00000262
    x/100x 0x10800000
    lock_otp
end

# ME10 Set HIRC96 frequency to 40MHz (for emulator at 20 MHz with PSC set to DIV2)
define me10_write_HIRC96_override_40Mhz
    unlock_otp
    write_flash 0x10800078 0x2d00229f
    write_flash 0x1080007c 0x00000131
    x/100x 0x10800000
    lock_otp
end

define me10_write_enable_secure_rom
    unlock_otp
    write_flash 0x10800300 0xffffffff
    write_flash 0x10800304 0xffffff5a
    x/100x 0x10800000
    lock_otp
end
document me10_write_enable_secure_rom
    ME10 Enable secure ROM to run (this ROM enable functionality is called enable TPU by the ROM code)
end

define me10_write_patch_addr
    unlock_otp
    # Write the location of the patch to 0x340 (address 0x102ffd80)
    write_flash 0x10800340 0xfec01cc8
    write_flash 0x10800344 0x80000817
    lock_otp
end
document me10_write_patch_addr
    ME10 Write patch base address
end

define me10_read_patch_area
    set $patch_addr=0x102ffd80
    printf "ME10 Production Patch Area: 0x%08X\n",$patch_addr
    x/160 $patch_addr
end
document me10_read_patch_area
    ME10 Read production patch flash area
end

define me10_write_rom_basics
    unlock_otp
    # Write USN
    write_flash 0x10800000 0x80028000
    write_flash 0x10800004 0x00f7e6d5
    write_flash 0x10800008 0x00800000
    write_flash 0x1080000c 0x7b66d581
    write_flash 0x10800010 0x00570000
    write_flash 0x10800014 0x00000000
    # Write FTM
    write_flash 0x10800020 0x5a5aa5a5
    write_flash 0x10800024 0x5a5aa5a5
    # Write LCP5 Pattern #1
    write_flash 0x10800040 0x00003800
    write_flash 0x10800044 0xd9455305
    # Write LCP5 Pattern #2
    write_flash 0x10800048 0x00003800
    write_flash 0x1080004c 0xd9455305
    x/100x 0x10800000
    lock_otp
end
document me10_write_rom_basics
    ME10 Write USN and other stuff test writes in during production
end

define me10_dumpclocks
    # Dump GCR.SCON
    x/1x 0x40000000
    # Dump GCR.CLKCN
    x/1x 0x40000008
end
document me10_dumpclocks
    ME10 Dump clock and OVR related information
end

define me10_override_HIRC96
    set buffer = {0x00,0x5a,0x62,0x02}
end
document me10_override_HIRC96
    ME10 override_HIRC96 to 40MHz in SystemCoreClockUpdate()
end