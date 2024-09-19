#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME18 Area
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

define write_fmv_me18
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write FMV (0x10, 0xff in lower words when USN is located, pattern in 0x18)
    write_flash_128 $write_addr+0x0010 0xffffffff 0xffffffff 0x5a5aa5a5 0x5a5aa5a5
    lock_otp
end

define write_ftm_me18
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write FTM (0x20, 0xff in upper words where TM is located, pattern in 0x20)
    write_flash_128 $write_addr+0x0020 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff
    lock_otp
end

define write_tm_me18
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write TM (0x20, 0xff in lower words where FTM is located, pattern in 0x28)
    write_flash_128 $write_addr+0x0020 0xffffffff 0xffffffff 0x5a5aa5a5 0x5a5aa5a5
    lock_otp
end

define me18_init
    set variable $me18_infoblock_read_address=0x10800000
    #  set variable $me18_infoblock_write_address=0x00280000
    set variable $me18_infoblock_write_address=0x00300000
    printf "Using ME18 Infoblock write offset %X\n",$me18_infoblock_write_address
end

# Dump known areas of ME21 Information Block
define me18_otp_smartdump
    # ME18 is only device requiring cache flush to read
    # infoblock.  Do other devices not cache the infoblock?
    # NOTE: icc0_flush works whether icc0 cache is enabled or not.  I
    #       did not see a lockup.
    icc0_flush

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $base = $me18_infoblock_read_address

    print "ME18 Info Block Dump"
    unlock_otp
    printf "Base Address: 0x%X\n",$base
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

    print "CRK1 Dump"
    x/22x $base+0x1000
    print "CRK1 Sig Dump"
    x/22x $base+0x1060
    print "Partial CRK2 Dump"
    x/22x $base+0x10C0
    print "Partial CRK2 Sig Dump"
    x/22x $base+0x1120

    print "FLV Procedure Parameters (A3)"
    x/4x $base+0xa0
    print "Override IPO Frequency"
    x/4x $base+0xb0
    print "Override IBRO Frequency"
    x/4x $base+0xc0
    print "Override ISO Frequency"
    x/4x $base+0xd0
    print "ROM Code Checksum Enable (A1/A2)"
    x/4x $base+0x100
    print "ROM Mode Area"
    x/4x $base+0x300
    print "Patch Address"
    x/4x $base+0x370
    print "Patch Data"
    x/16x $base+0x800
    print "HHA Location"
    x/4x $base+0x1180
    print "Binary Location"
    x/4x $base+0x1190
    print "USB Disable"
    x/4x $base+0x540
    print "UART Disable"
    x/4x $base+0x5C0
    print "UART Timeout"
    x/4x $base+0x5D0
    print "UART Params"
    x/4x $base+0x5E0
    print "VBUS Disable"
    x/4x $base+0x600
    print "Register Write 0"
    x/4x $base+0x700
    print "Register Write 1"
    x/4x $base+0x710
    print "Bootloader Entry Delay (A3)"
    x/4x $base+0x780
    lock_otp
end

define me18_write_flv_params
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp

    # Write FLV parameters, delay0=1uS, delay1=50uS
    #  write_flash_128 $write_addr+0x00a0 0x1900ee6a 0x00000000 0xffffffff 0xffffffff
    # Write FLV parameters, delay0=16uS, delay1=128uS
    write_flash_128 $write_addr+0x00a0 0x400864c2 0x00000000 0xffffffff 0xffffffff

    lock_otp
end

define me18_write_cache_disable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp

    # Disable ICC0 Cache
    # Write register 0x4002a100, mask 0x00000001, value 0x00000000
    write_flash_128 $write_addr+0x0700 0x50800703 0x0000a001 0x00001715 0x00000000
    # Disable ICC1 Cache
    # Write register 0x4002a900, mask 0x00000001, value 0x00000000
    write_flash_128 $write_addr+0x0710 0x54806b26 0x0000a001 0x00001715 0x00000000

    lock_otp
end

define me18_write_lcp5_yesphase5_a1a2
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp

    # Write LCP#5 Pattern 1 (64-bit OTP lock bit)
    write_flash $write_addr+0x0040 0x00003800
    write_flash $write_addr+0x0044 0xd9455305
    # Write LCP#5 Pattern 2 (64-bit OTP lock bit)
    write_flash $write_addr+0x0050 0x00003800
    write_flash $write_addr+0x0054 0xd9455305

    lock_otp
end

define me18_write_lcp5_nophase5_a3
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp

    # Write LCP#5 Pattern 1 (64-bit OTP lock bit, NO_PHASE5)
    write_flash $write_addr+0x0040 0x00000A54
    write_flash $write_addr+0x0044 0x59455305
    # Write LCP#5 Pattern 2 (64-bit OTP lock bit, NO_PHASE5)
    write_flash $write_addr+0x0050 0x00000A54
    write_flash $write_addr+0x0054 0x59455305

    lock_otp
end

define me18_write_secure_rom_basics_yesphase5_a1a2
    me18_wri`te_usn
    write_fmv_me18
    write_ftm_me18
    write_tm_me18
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write LCP5 Values
    me18_write_lcp5_yesphase5_a1a2

    unlock_otp

    # Write IPO Override Word (set to 48MHz for emulator) (offset 0xB0)
    #  write_flash $write_addr+0x00b0 0x36007629
    #  write_flash $write_addr+0x00b4 0x0000016e
    # Write IBRO Override Word (set to 7.3728MHz) (offset 0xC0)
    #  write_flash $write_addr+0x00c0 0x40006e0a
    #  write_flash $write_addr+0x00c4 0x00000038

    lock_otp

    # Write ME18 ROM Mode
    me18_write_rom_enable

    # Disable VBUS.
    #  me18_wri`te_vbus_disable
end

define me18_write_secure_rom_basics_nophase5_a3
    me18_write_usn
    write_fmv_me18
    write_ftm_me18
    write_tm_me18
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write LCP5 Values
    me18_write_lcp5_nophase5_a3

    unlock_otp

    # Write IPO Override Word (set to 48MHz for emulator) (offset 0xB0)
    #  write_flash $write_addr+0x00b0 0x36007629
    #  write_flash $write_addr+0x00b4 0x0000016e
    # Write IBRO Override Word (set to 7.3728MHz) (offset 0xC0)
    #  write_flash $write_addr+0x00c0 0x40006e0a
    #  write_flash $write_addr+0x00c4 0x00000038

    lock_otp

    # Write ME18 ROM Mode
    me18_write_rom_enable

    # Disable VBUS.
    #  me18_write_vbus_disable
end

# Write patterns to disable the secure ROM.
define me18_write_disable_rom_basics
    me18_write_usn
    write_fmv_me18
    write_ftm_me18
    write_tm_me18

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address
    #  printf "ME18 Infoblock Write Address: 0x%X\n",$write_addr
    unlock_otp

    lock_otp

    # Write ME18 ROM Mode
    me18_write_rom_disable
    # Write ME18 ROM Checksum
    #  me18_write_rom_checksum_enable
end

define me18_write_usb_disable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write USB Disable Pattern (offset 0x540)
    write_flash_128 $write_addr+0x0540 0x52d28268 0x00002d2d 0xffffffff 0xffffffff
    lock_otp
end

define me18_write_uart_disable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write UART Disable Pattern (offset 0x5D0)
    write_flash_128 $write_addr+0x05C0 0x52d28268 0x00002d2d 0xffffffff 0xffffffff
    lock_otp
end

define me18_write_vbus_disable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write USB VBUS Disable Pattern (offset 0x600)
    write_flash_128 $write_addr+0x0600 0x52d28268 0x00002d2d 0xffffffff 0xffffffff
    lock_otp
end

define me18_write_rom_checksum_enable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp

    # Write ROM Checksum Enable Word (offset 0x100)
    write_flash_128 $write_addr+0x0100 0x5a5aa5a5 0x5a5aa5a5 0x00000000 0x00000000

    lock_otp
end

define me18_write_rom_disable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    # Write ROM Disable Pattern (offset 0x300)
    write_flash_128 $write_addr+0x0300 0x5a5aa5a5 0x5a5aa5a5 0x00000000 0x00000000
    lock_otp
end

define me18_write_rom_enable
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address
    #  printf "ME18 Infoblock Write Address: 0x%X\n",$write_addr

    unlock_otp
    # Write ROM Enable Pattern (offset 0x300)
    write_flash_128 $write_addr+0x0300 0x00000000 0x00000000 0x00000000 0x00000000
    lock_otp
end

define me18_write_dev_crk
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address
    #  printf "ME18 Infoblock Write Address: 0x%X\n",$write_addr

    unlock_otp

    # *****************************************************************************
    # Development CRK signed with ME18 production MRK (with crk signature at 0x1050), 64-bit OTP lock bit
    # *****************************************************************************
    # CRK
    write_flash_128 $write_addr+0x1000 0x11d47194 0x243cc2e4 0xb46e6a5a 0x799f1d47
    write_flash_128 $write_addr+0x1010 0x797b3c31 0x780a5290 0x162e4a2b 0x46778e36
    write_flash_128 $write_addr+0x1020 0x97cfb3f6 0x678ef8c6 0xa1008ea3 0x3092709d
    write_flash_128 $write_addr+0x1030 0xddce5fc6 0x42f4a8f5 0x47191d30 0x10e999c7
    write_flash_128 $write_addr+0x1040 0xef65302a 0x6046310c 0x21edd060 0x13bda518
    write_flash_128 $write_addr+0x1050 0x6df976c5 0x00007f47 0xffffffff 0xffffffff

    # CRK Signature
    write_flash_128 $write_addr+0x1060 0x351156b0 0x3140b613 0xd1c6dbdb 0x379f5ee4
    write_flash_128 $write_addr+0x1070 0xa30647a0 0x67764777 0x418b74b8 0x60c86081
    write_flash_128 $write_addr+0x1080 0x3a8f8bb6 0x0117cdb0 0xb5a83a6f 0x13f777b5
    write_flash_128 $write_addr+0x1090 0x5dc5691a 0x0700e42c 0xadf6158b 0x532b1be0
    write_flash_128 $write_addr+0x10a0 0xeee9a29a 0x33a2d89d 0x20c8037a 0x386d202c
    write_flash_128 $write_addr+0x10b0 0x93fdff3d 0x00000122 0xffffffff 0xffffffff

    lock_otp
end

define me18_write_dev_crk2
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address
    #  printf "ME18 Infoblock Write Address: 0x%X\n",$write_addr

    unlock_otp

    # *****************************************************************************
    # Development CRK2 signed with ME18 production MRK (with crk signature at 0x1120), 64-bit OTP lock bit
    # *****************************************************************************
    # CRK2
    write_flash_128 $write_addr+0x10c0 0x35178ce9 0x26f86bee 0xe2a20e24 0x24f09ee7
    write_flash_128 $write_addr+0x10d0 0x970988f5 0x68626931 0x850620d6 0x26a9555c
    write_flash_128 $write_addr+0x10e0 0xb2bafc73 0x10d46282 0xbe5051f9 0x11473bba
    write_flash_128 $write_addr+0x10f0 0xbe15ebea 0x10d3c6fb 0x206a93ec 0x742b02e2
    write_flash_128 $write_addr+0x1100 0x93abcb0b 0x405450c5 0x1a06b6c5 0x68b5eb36
    write_flash_128 $write_addr+0x1110 0xd4be97a6 0x00006dda 0xffffffff 0xffffffff

    # CRK2 Signature
    write_flash_128 $write_addr+0x1120 0x33b2d3f8 0x77a75ae2 0xe246e0f4 0x091e851c
    write_flash_128 $write_addr+0x1130 0xcde6a6f6 0x16f1a34a 0x33063a80 0x45591a41
    write_flash_128 $write_addr+0x1140 0x60bef148 0x6da17f2f 0x9ea84beb 0x56ecbd05
    write_flash_128 $write_addr+0x1150 0x050b61a0 0x74927e95 0x2ef1e4cc 0x203f72ec
    write_flash_128 $write_addr+0x1160 0xdc0edf1e 0x1a0620cf 0x41bf28ab 0x2431939a
    write_flash_128 $write_addr+0x1170 0xbdae09ab 0x0000734b 0xffffffff 0xffffffff

    lock_otp
end

# Write ME18 TRNG registers to trim values similar to ME21 infoblock as of April 19, 2021
# These values cause the TRNG read to take > 800us instead of 4us.
define me18_write_rng_trim_regs
    tme_on
    # I do not have documention for these values.  They are copied to the
    # NBBSIR registers from the Infoblock after a POR.
    # NBB SIR16
    set *0x40000440=0xf8e2020c
    print "SIR16"
    x/x 0x40000440
    # NBB SIR17
    set *0x40000444=0x00000028
    print "SIR17"
    x/x 0x40000444
    tme_off
end

# Write ME18 TRNG registers to trim values suggested by Dave Ortte in May 2021
# These values are based on ES60 TRNG behavior/trim.
define me18_write_rng_trim_regs_dave_ortte
    tme_on
    # I do not have documention for these values.  They are copied to the
    # NBBSIR registers from the Infoblock after a POR.
    # NBB SIR16
    set *0x40000440=0x0011020c
    print "SIR16"
    x/x 0x40000440
    # NBB SIR17
    set *0x40000444=0x00000000
    print "SIR17"
    x/x 0x40000444
    tme_off
end

# Read ME18 TRNG trim registers.
define me18_read_rng_trim_regs
    # NBB SIR16
    print "SIR16"
    x/x 0x40000440
    # NBB SIR17
    print "SIR17"
    x/x 0x40000444
end

define me18_write_usn
    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    unlock_otp
    write_flash_128 $write_addr+0x0000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    write_flash_128 $write_addr+0x0010 0x00570000 0x00000000 0xffffffff 0xffffffff
    lock_otp
end

define me18_testcase_loadrom
    print "Loading ROM"
    restore /home/bryan/work/Romcode/me18/tags/me18a3_rom_rc2/build/me18rom.bin binary 0
    file /home/bryan/work/Romcode/me18/tags/me18a3_rom_rc2/build/me18rom.elf
    compare-sections
end

# FTM, LCP5_1, LCP5_2, ROM checksum correct, SCP stimulus applied, working application
define me18_testcase_1_01
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    # Write FTM
    write_ftm_me18

    # Write LCP5 Values
    #  me18_write_lcp5_yesphase5_a1a2
    me18_write_lcp5_nophase5_a3

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# FTM unprogrammed, SCP stimulus applied, no application
define me18_testcase_1_03
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    # Write LCP5 Values
    #  me18_write_lcp5_yesphase5_a1a2
    me18_write_lcp5_nophase5_a3

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# FTM one correct pattern, SCP stimulus applied, no application
define me18_testcase_1_04
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    unlock_otp
    # Write Partial FTM
    write_flash_128 $write_addr+0x0020 0xffffa5a5 0xffffffff 0xffffffff 0xffffffff
    lock_otp

    # Write LCP5 Values
    #  me18_write_lcp5_yesphase5_a1a2
    me18_write_lcp5_nophase5_a3

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# FTM two correct patterns, SCP stimulus applied, no application
define me18_testcase_1_05
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    unlock_otp
    # Write Partial FTM
    write_flash_128 $write_addr+0x0020 0x5a5aa5a5 0xffffffff 0xffffffff 0xffffffff
    lock_otp

    # Write LCP5 Values
    #  me18_write_lcp5_yesphase5_a1a2
    me18_write_lcp5_nophase5_a3

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# ROM checksum incorrect, SCP stimulus applied, no application
define me18_testcase_1_06
    # Get normal values into infoblock
    me18_testcase_1_01

    print "ROM CRC Before bit flip"
    x/wx 0x1fffc
    # Corrupt the checksum, invert bit 0
    set *0x1FFFC = *0x1FFFC ^ 1
    print "ROM CRC After bit flip"
    x/wx 0x1fffc
end

# LCP5_1/LCP5_2 unprogrammed, SCP stimulus applied, no application
define me18_testcase_1_07
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    # Write FTM
    write_ftm_me18

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# LCP5_1 corrupted, LCP5_2, SCP stimulus applied, no application
define me18_testcase_1_08
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    # Write FTM
    write_ftm_me18

    unlock_otp
    # Write Incorrect LCP#5 Pattern 1 (64-bit OTP lock bit, NO_PHASE5)
    write_flash $write_addr+0x0040 0x00000A55
    write_flash $write_addr+0x0044 0x59455305
    # Write LCP#5 Pattern 2 (64-bit OTP lock bit, NO_PHASE5)
    write_flash $write_addr+0x0050 0x00000A54
    write_flash $write_addr+0x0054 0x59455305

    # Write Incorrect LCP#5 Pattern 1 (64-bit OTP lock bit)
    #  write_flash $write_addr+0x0040 0x00003801
    #  write_flash $write_addr+0x0044 0xd9455305
    # Write LCP#5 Pattern 2 (64-bit OTP lock bit)
    #  write_flash $write_addr+0x0050 0x00003800
    #  write_flash $write_addr+0x0054 0xd9455305
    lock_otp

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# LCP5_1, LCP5_2 corrupted, SCP stimulus applied, no application
define me18_testcase_1_09
    # Load the ROM image
    me18_testcase_loadrom

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $write_addr = $me18_infoblock_write_address

    # Write USN
    me18_write_usn

    # Write FTM
    write_ftm_me18

    unlock_otp
    # Write Incorrect LCP#5 Pattern 1 (64-bit OTP lock bit, NO_PHASE5)
    write_flash $write_addr+0x0040 0x00000A54
    write_flash $write_addr+0x0044 0x59455305
    # Write LCP#5 Pattern 2 (64-bit OTP lock bit, NO_PHASE5)
    write_flash $write_addr+0x0050 0x00000A55
    write_flash $write_addr+0x0054 0x59455305

    # Write LCP#5 Pattern 1 (64-bit OTP lock bit)
    #  write_flash $write_addr+0x0040 0x00003800
    #  write_flash $write_addr+0x0044 0xd9455305
    # Write Incorrect LCP#5 Pattern 2 (64-bit OTP lock bit)
    #  write_flash $write_addr+0x0050 0x00003801
    #  write_flash $write_addr+0x0054 0xd9455305
    lock_otp

    # Enable ROM checksum (A1/A2)
    #  me18_write_rom_checksum_enable
end

# CRK Load Signature Corrupt Script
define me18_testcase_CRK_sig_corrupt
    # Load the ROM image
    me18_testcase_loadrom
    # Set up for Secure Rom
    #  me18_write_secure_rom_basics_yesphase5_a1a2
    me18_write_secure_rom_basics_nophase5_a3

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $base = $me18_infoblock_read_address

    # Reset part
    mrh
    # Remove any existing breakpoints
    d

    tb cm_user_write_crk
    print "Waiting for SCP Packet"
    c
    # Send Write CRK command over SCP here

    # Breakpoint at signature check and corrupt signature.
    tb sh_check_signature
    c
    set *p_signature=*p_signature+1
    tb pm_scp_send_response_simple
    c
    # Allow pm_scp_send_response_simple to complete
    fin
    # Infoblock will be unchanged and SCP error message sent over comm channel
    print "CRK1 or CRK2 should remain unwritten (0xFF)"
    unlock_otp
    print "CRK Storage"
    x/20x $base+0x1000
    print "CRK2 Storage"
    x/20x $base+0x10C0
    lock_otp
end

# ReWrite CRK, original CRK1 Corrupt Script
define me18_testcase_RewriteCRK_corrupt
    # Load the ROM image
    me18_testcase_loadrom
    # Set up for Secure Rom
    #  me18_write_secure_rom_basics_yesphase5_a1a2
    me18_write_secure_rom_basics_nophase5_a3

    # Set part specific infoblock base address
    me18_init
    # Set shorter length local variable address
    set variable $base = $me18_infoblock_read_address

    # Reset part
    mrh
    # Remove any existing breakpoints
    d

    tb pm_scp_treat_command
    print "Waiting for SCP Packet"
    c
    # Send Write CRK command over SCP here

    # Breakpoint at signature check and corrupt signature.
    tb cm_read_user_param
    c
    # Allow cm_read_user_param to complete
    fin
    set *p_oldcrk=*p_oldcrk+1
    tb pm_scp_send_response_simple
    c
    # Allow pm_scp_send_response_simple to complete
    fin
    # Infoblock will be unchanged and SCP error message sent over comm channel
    print "CRK2 should be unwritten (0xFF)"
    unlock_otp
    print "CRK Storage"
    x/20x $base+0x1000
    print "CRK2 Storage"
    x/20x $base+0x10C0
    lock_otp
end