
#***************************************************************************
#***************************************************************************
#***************************************************************************
# ES17 Area
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

define disable_encryption
    # Save old SCON value
    set variable $old_scon=*$scon_addr
    # Turn off encryption (bit 20) so we can access the information block
    set *$scon_addr = $scon_addr & ~0x100000
end

define restore_encryption
    # Restore SCON
    set *$scon_addr = $old_scon
end

define enable_encryption
    # Turn on encryption (bit 20)
    set *$scon_addr = $scon_addr | 0x100000
end

define otp_smartdump
    print "Info Block Dump"
    # Base address of information block
    set variable $base=0x10800000
    # Disable encryption in SCON
    disable_encryption
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
    x/2x $base+0x40
    print "LCP#5 Pattern 2"
    x/2x $base+0x48
    print "PUF KeyGen Magic Word"
    x/2x $base+0x60
    print "TRNG Keygen Magic Word"
    x/2x $base+0x68
    print "SCP Deact SPI"
    x/2x $base+0x80
    print "SCP Deact UART"
    x/2x $base+0x88
    print "Override HIRC Frequency"
    x/2x $base+0x90
    print "Override HIRC8 Frequency"
    x/2x $base+0x98
    print "ROM Code Checksum Enable"
    x/2x $base+0x100
    print "Classic UART Enable"
    x/2x $base+0x190
    print "UART Parameters"
    x/2x $base+0x268
    print "SCP entry stimulus"
    x/2x $base+0x270
    print "CSPI Config"
    x/2x $base+0x300
    print "Partial CRK1 Dump"
    x/8x $base+0x1000
    print "Partial CRK2 Dump"
    x/8x $base+0x10b0
    print "OTP_BINARY_OFFSET"
    x/2x $base+0x1168
    print "UART Alternate Clock (not used on ES17, using Classic UART)"
    x/2x $base+0x1170
    print "ECCEN Value"
    x/2x $base+0x1178
    print "CLKCN_WRITE_0"
    x/2x $base+0x1180
    print "PUF Key Pairing Information (up to 2KB)"
    x/16x $base+0x4000
    print "TRNG OTP Key (1KB)"
    x/16x $base+0x4800
    lock_otp
    # Restore SCON
    restore_encryption
end
document otp_smartdump
    Dump known areas of Information Block
end

define write_pufkeylockword
    # Disable encryption in SCON
    disable_encryption
    unlock_otp
    # Write PUF Key Lock Word (offset 0x60)
    write_flash 0x00800060 0xffffa5a5
    write_flash 0x00800068 0xffffffff
    x/10x 0x10800060
    lock_otp
    # Restore SCON
    restore_encryption
end
document write_pufkeylockword
    Write PUF Key Lock Work. This activates PUF to generate key on next POR.
end

define whichUARTeh
    # Show Test Mode Enable
    print "TME set if bit 0 set."
    x/1x 0x40000c00
    # SIR4?
    print "Classic UART If bit 30 and 14 are set. SIR4?"
    x/1x 0x40000410
end

define cspi_addr
    # Show CSPI addresses
    print "flash_sba and flash_sta"
    x/2x 0x400A0414
end

define enable_classic_uart
    # Disable encryption in SCON
    disable_encryption
    unlock_otp

    # Write value to switch from "New" to "Classic" UART

    # Write FMV (this value required to enable OTP to shadow register moves on POR)
    write_flash 0x00800018 0xffffa5a5
    write_flash 0x0080001C 0xffffffff
    # NBB header row, HEADER1 (for transfer?)
    write_flash 0x00800180 0x00070008
    write_flash 0x00800184 0x6ac00000
    # SICFG0/1 with zero (from Frank on Feb 1, 2019)
    write_flash 0x00800188 0x00000000
    write_flash 0x0080018C 0x00000000
    # Write SIR4/5 register (to enable Classic UART)
    write_flash 0x00800190 0x40004000
    write_flash 0x00800194 0xfcf9ffff

    lock_otp
    # Restore SCON
    restore_encryption
end
document enable_classic_uart
    Enable Classic UART
end

define write_rom_basics
    # Disable encryption in SCON
    disable_encryption

    unlock_otp

    # Write USN
    # write_flash_128 0x00800000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    # write_flash 0x00800010 0x00570000
    # write_flash 0x00800014 0x00000000
    # Write FTM
    write_flash 0x10800020 0x5a5aa5a5
    write_flash 0x10800024 0x5a5aa5a5
    # Write LCP#5 Pattern 1
    write_flash 0x10800040 0x00003800
    write_flash 0x10800044 0xd9455305
    # Write LCP#5 Pattern 2
    write_flash 0x10800048 0x00003800
    write_flash 0x1080004C 0xd9455305
    # Write PUF Key Lock Word (offset 0x60)
    # write_flash 0x00800060 0xffffa5a5
    # write_flash 0x00800064 0xffffffff
    # Write Deactivate SPI Word (offset 0x80)
    write_flash 0x00800080 0x52d28268
    write_flash 0x00800084 0x00002d2d
    # Write HIRC Override Word (set to 40MHz) (offset 0x80)
    # write_flash 0x00800090 0x2d00229f
    # write_flash 0x00800094 0x00000131
    # Write SLA binary offset (set to 0x1000C000, internal flash) (offset 0x1168)
    write_flash 0x00801168 0x6000281c
    write_flash 0x0080116C 0x00800800

    lock_otp
    # Restore SCON
    restore_encryption
end
document write_rom_basics
    Write USN and other stuff test writes in during production
end