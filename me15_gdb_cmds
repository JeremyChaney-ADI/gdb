

#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME15 Area
#***************************************************************************
#***************************************************************************
#***************************************************************************

define unlock_otp
    # Write acntl to unlock OTP
    lock_otp
    set *$fctl_acntl=0x3a7f5ca3
    set *$fctl_acntl=0xa1e34f20
    set *$fctl_acntl=0x9608b2c1
end

define write_rom_basics
    unlock_otp
    # Write USN
    write_flash_128 0x00080000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    write_flash_128 0x00080010 0x00570000 0x00000000 0xffffffff 0xffffffff

    # Write FMV (0x10, 0xff in lower words when USN is located, pattern in 0x18)
    write_flash_128 0x00080010 0xffffffff 0xffffffff 0x5a5aa5a5 0x5a5aa5a5

    lock_otp
end