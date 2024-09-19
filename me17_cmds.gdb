#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME17 Area
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

define me17_otp_smartdump
    print "ME17 Info Block Dump"
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
    print "ROM Code Checksum Enable"
    x/4x $base+0x100
    print "HEADER1"
    x/2x $base+0x180
    print "SICFG0/1"
    x/2x $base+0x188
    print "Secure Boot Enable/Disable (NBBSIR6/7)"
    x/2x $base+0x198
    print "ECDSA Public Key Dump"
    x/24x $base+0x1000
    lock_otp
end
document me17_otp_smartdump
    Dump known areas of ME17 Information Block
end

define me17_sysinitstat
    # All NBBSIR base is 0x40000400, Non-Battery Backed SI Registers (SIR)
    # All NBBFCR base is 0x40000800, Non-Battery Backed Function Control Registers
    # Set TME=1
    tme_on
    tme_print
    print "TMR"
    x/x 0x40000C00
    print "SISTAT"
    x/x 0x40000400
    print "SIADDR"
    x/x 0x40000404
    print "SICFG0"
    x/x 0x40000408
    print "SICFG1"
    x/x 0x4000040C
    print "SIR4"
    x/x 0x40000410
    print "SIR5"
    x/x 0x40000414
    print "SIR6"
    x/x 0x40000418
    print "SIR7"
    x/x 0x4000041C
    print "FSTAT"
    x/x 0x40000500
    print "SFSTAT"
    x/x 0x40000504
    # Set TME=0
    tme_off
    tme_print
    print "TMR"
    x/x 0x40000C00
end

define me17_write_secboot_enable
    unlock_otp
    # Write Header to a value and SICFG0/1 to all zero
    # write_flash_128 0x00080180 0x00070008 0x6ac00000 0x00000000 0x00000000
    # From Hiep, Write Header to a value and SIGCFG0/1 to all zeros
    write_flash_128 0x00080180 0x40000408 0x7d020009 0x00000000 0x00000000
    # Write NBBSIR4/5/6/7 (SIR6[3:0]=0 and SIR6[20:16]=0 means SFSTAT.0=1, secure boot enabled
    write_flash_128 0x00080190 0x00000000 0x00000000 0x00000000 0x00000000
    # Write more zeros (NBBSIR8/9/10/11)
    write_flash_128 0x000801A0 0x00000000 0x00000000 0x00000000 0x00000000
    # Write more zeros (NBBSIR12/13/14/15)
    write_flash_128 0x000801B0 0x00000000 0x00000000 0x00000000 0x00000000
    # Write more zeros (NBBSIR16/17/18/19)
    write_flash_128 0x000801C0 0x00000000 0x00000000 0x00000000 0x00000000
    lock_otp

    # Write FMV to enable SysInit to read the above values
    write_fmv
end
document me17_write_secboot_enable
    Write Infoblock to enable secure boot (SFSTAT.0=1 from this infoblock pattern)
end

define me17_write_secboot_disable
    unlock_otp
    # Write Header to a value and SICFG0/1 to all zero
    # write_flash_128 0x00080180 0x00070008 0x6ac00000 0x00000000 0x00000000
    # From Hiep, Write Header to a value and SIGCFG0/1 to all zeros
    write_flash_128 0x00080180 0x40000408 0x7d020009 0x00000000 0x00000000
    # Write NBBSIR4/5/6/7 (SIR6[3:0]=a and SIR6[20:16]=a means SFSTAT.0=0, secure boot disabled
    write_flash_128 0x00080190 0x00000000 0x00000000 0x000a000a 0x4c400000
    # Write more zeros (NBBSIR8/9/10/11)
    write_flash_128 0x000801A0 0x00000000 0x00000000 0x00000000 0x00000000
    # Write more zeros (NBBSIR12/13/14/15)
    write_flash_128 0x000801B0 0x00000000 0x00000000 0x00000000 0x00000000
    # Write more zeros (NBBSIR16/17/18/19)
    write_flash_128 0x000801C0 0x00000000 0x00000000 0x00000000 0x00000000
    lock_otp

    # Write FMV to enable SysInit to read the above values
    write_fmv
end
document me17_write_secboot_disable
    Write Infoblock to disable secure boot (SFSTAT.0=0 from this infoblock pattern)
end

define me17_write_rom_basics
    unlock_otp
    # Write USN
    write_flash_128 0x00080000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    write_flash_128 0x00080010 0x00570000 0x00000000 0xffffffff 0xffffffff
    # Write FTM (0x20, 0xff in upper words where TM is located)
    write_flash_128 0x00080020 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff
    # ROM Checksum Enable
    #write_flash_128 0x00080100 0x5a5aa5a5 0x5a5aa5a5 0x00000000 0x00000000
    # ICE_LOCK Enable
    #write_flash_128 0x00080030 0x5a5aa5a5 0x5a5aa5a5 0x00000000 0x00000000
    x/100x 0x10800000
    lock_otp
end
document me17_write_rom_basics
    ME17 Write USN and other stuff test engineering writes in during production
end

define me17_write_zero_key
    unlock_otp
    # Write a zero key to key area.
    # 64 bytes, 6 bytes of key per area.
    # When overhead is included, 11 64-bit values must be written
    write_flash_128 0x00081000 0x00000000 0x00000000 0x00000000 0x00000000 
    write_flash_128 0x00081010 0x00000000 0x00000000 0x00000000 0x00000000 
    write_flash_128 0x00081020 0x00000000 0x00000000 0x00000000 0x00000000 
    write_flash_128 0x00081030 0x00000000 0x00000000 0x00000000 0x00000000 
    write_flash_128 0x00081040 0x00000000 0x00000000 0x00000000 0x00000000 
    write_flash_128 0x00081050 0x00000000 0x00000000 0xffffffff 0xffffffff 
    x/24x 0x10801000
    lock_otp
end
document me17_write_zero_key
    ME17 Write all zeros to key area.
end

define me17_write_ones_key
    unlock_otp
    # Write a ones key to key area.
    # 64 bytes, 6 bytes of key per area.
    # When overhead is included, 11 64-bit values must be written
    write_flash_128 0x00081000 0xffffffff 0x522fffff 0xffffffff 0x522fffff 
    write_flash_128 0x00081010 0xffffffff 0x522fffff 0xffffffff 0x522fffff 
    write_flash_128 0x00081020 0xffffffff 0x522fffff 0xffffffff 0x522fffff 
    write_flash_128 0x00081030 0xffffffff 0x522fffff 0xffffffff 0x522fffff 
    write_flash_128 0x00081040 0xffffffff 0x522fffff 0xffffffff 0x522fffff 
    write_flash_128 0x00081050 0xffffffff 0x522fffff 0xffffffff 0xffffffff 
    x/24x 0x10801000
    lock_otp
end
document me17_write_ones_key
    ME17 Write all ones key to key area.
end

define me17_write_simulation_test_key
    unlock_otp
    # Write the test ECDSA public key to key area.
    # 64 bytes, 6 bytes of key per area.
    # When overhead is included, 11 64-bit values must be written
    write_flash_128 0x00081000 0xfae4d7b2 0x38a42058 0x1ecade50 0x32cf34e4
    write_flash_128 0x00081010 0x7f608f8f 0x78560525 0x25ca91a9 0x69467e8f
    write_flash_128 0x00081020 0x13a3829e 0x256c54db 0x1c78e595 0x3849f72f
    write_flash_128 0x00081030 0x2330359e 0x66b6df87 0x2f58f342 0x13d6172d
    write_flash_128 0x00081040 0xe5a98b36 0x64ed6e9e 0xd7cbb23b 0x74220941
    write_flash_128 0x00081050 0x81608ac3 0x7fa90000 0x00000000 0x00000000
    x/24x 0x10801000
    lock_otp
end
document me17_write_simulation_test_key
    ME17 Write simulation test key (8 byte "OTP Lines").
    NOTE: The ME17 has 128-bit wide flash, so the OTP Line Lock is bit 127 
    instead of bit 63 as used here.  The ROM may be changing to resolve this problem.
end