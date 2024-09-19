

#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME21 Area
#***************************************************************************
#***************************************************************************
#***************************************************************************

define unlock_otp
    # Write acntl to unlock OTP on me21
    set *$fctl_acntl=0xdeadbeef
    set *$fctl_acntl=0xaeefd679
    set *$fctl_acntl=0x5f92525a
    set *$fctl_acntl=0x65fbc805
end

define write_fmv
    unlock_otp
    # Write FMV (0x10, 0xff in lower words when USN is located, pattern in 0x18)
    write_flash_128 0x00080010 0xffffffff 0xffffffff 0x5a5aa5a5 0x5a5aa5a5
    lock_otp
end

define placeholdername

    write_dev_crk

    mrh
    load

end

define write_dev_crk
    # Development CRK signed with ME21 production MRK (with crk signature at 0x1050)
    unlock_otp
    # CRK
    write_flash_128 0x00081000 0x11d4296f 0x243cc2e4 0x1d47b46e 0x797b799f
    write_flash_128 0x00081010 0x52903f65 0x162e780a 0xc6778e36 0x78c697cf
    write_flash_128 0x00081020 0xe78e8c5a 0x709da100 0xddce3092 0x42f4a8f5
    write_flash_128 0x00081030 0x47193bc7 0x10e999c7 0x310cef65 0x21ede046
    write_flash_128 0x00081040 0xa5183b4b 0x6df913bd 0x00007f47 0x00000000

    # CRK Signature (New memory map, starting address compatible with 64-bit info block in future)
    write_flash_128 0x00081060 0x453db735 0xd5730fbf 0xd815d91a 0x33f0739a
    write_flash_128 0x00081070 0x623ef6f4 0x91fe9814 0x188b79ea 0x68c3ccb6
    write_flash_128 0x00081080 0x980478cf 0xb473f79c 0x63a39670 0x02565b57
    write_flash_128 0x00081090 0x5659aecc 0x5757c863 0x15f6512b 0x309acb17
    write_flash_128 0x000810A0 0x0039592c 0x145f109c 0x00001088 0x00000000

    lock_otp
end

define me21_write_lcp5_pattern_phase5_disabled
    unlock_otp
    # Write LCP5 Pattern #1
    write_flash_128 0x00080040 0x00000A54 0x59455305 0x00000000 0x00000000
    # Write LCP5 Pattern #2
    write_flash_128 0x00080050 0x00000A54 0x59455305 0x00000000 0x00000000
    lock_otp
end
document me21_write_lcp5_pattern_phase5_disabled
    ME21B1 silicon does not have phase 5 (Use with B1 silicon only!)
end

define write_secure_rom_basics
    unlock_otp
    # Write USN
    write_flash_128 0x00080000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    write_flash_128 0x00080010 0x00570000 0x00000000 0xffffffff 0xffffffff
    # Write FTM - TAC => bueno???
    write_flash_128 0x00080020 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff
    # Write LCP5 Pattern #1
    write_flash_128 0x00080040 0x00001246 0x59455305 0x00000000 0x80000000
    # Write LCP5 Pattern #2
    write_flash_128 0x00080050 0x00001246 0x59455305 0x00000000 0x80000000
    # Write ROM Checksum Enable Word (offset 0x100)
    write_flash_128 0x00080100 0x5a5aa5a5 0x5a5aa5a5 0x00000000 0x00000000
    # TODO:
    # Write Deactivate ETH Word (offset 0x70)
    #  write_flash_128 0x00080070 0x52d28268 0x00002d2d 0x00000000 0x00000000
    # Write Deactivate USB Word (offset 0x80)
    #  write_flash_128 0x00080080 0x52d28268 0x00002d2d 0x00000000 0x00000000
    # Write Deactivate SPI Word (offset 0x90)
    #  write_flash_128 0x00080090 0x52d28268 0x00002d2d 0x00000000 0x00000000
    # Write Deactivate UART Word (offset 0xA0)
    #  write_flash_128 0x000800A0 0x52d28268 0x00002d2d 0x00000000 0x00000000
    # Write IPO Override Word (set to 48MHz for emulator) (offset 0xB0)
    #  write_flash_128 0x000800B0 0x36007629 0x0000016e 0x00000000 0x00000000
    # Write IPO Override Word (set to 100MHz) (offset 0xB0)
    #  write_flash_128 0x000800B0 0xf0804696 0x000002fa 0x00000000 0x00000000
    # Write IBRO Override Word (set to 7.3728MHz) (offset 0xC0)
    #  write_flash_128 0x000800C0 0x40006e0a 0x00000038 0x00000000 0x00000000
    # TODO: Write SLA binary offset (set to ??, internal flash) (offset ?)

    x/10x 0x10800000
    lock_otp

    # Write FMV
    write_fmv
    # Write TM - TAC => no bueno
    #write_tm_me21
end
document write_secure_rom_basics
    CAREFUL WITH THIS!: ME21 Write USN and other stuff test writes in during production
end

define write_info_0

    print "unlock OTP"
    unlock_otp

    x/4x 0x10800300

    print "write to info page"

    write_flash_128 0x00080300 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff

    print "re-lock info page"

    x/4x 0x10800300

    lock_otp

end

define set_gpio_high
    if $argc != 2
        printf "BOO! HISS! Try \"help set_gpio_high\"\n"
    else
        printf "INFO : setting GPIO%0d.%0d high.\n", $arg0, $arg1

        if $arg0 == 0
            # GPIO0 variables
            set variable $gpio_en0   = 0x40008000
            set variable $gpio_en1   = 0x40008068
            set variable $gpio_en2   = 0x40008074
            set variable $gpio_outen = 0x4000800C
            set variable $gpio_out   = 0x40008018
            set variable $gpio_inen  = 0x40008030
        else
            # GPIO1 variables
            set variable $gpio_en0   = 0x40009000
            set variable $gpio_en1   = 0x40009068
            set variable $gpio_en2   = 0x40009074
            set variable $gpio_outen = 0x4000900C
            set variable $gpio_out   = 0x40009018
            set variable $gpio_inen  = 0x40009030
        end

        set *$gpio_outen |=  (0x1 << $arg1)
        set *$gpio_en0   |=  (0x1 << $arg1)
        set *$gpio_en1   &= ~(0x1 << $arg1)
        set *$gpio_en2   &= ~(0x1 << $arg1)
        set *$gpio_inen  &= ~(0x1 << $arg1)
        set *$gpio_out   |=  (0x1 << $arg1)

    end
end
document set_gpio_high
    usage:
    set_gpio_low <port number> <pin number>

    outputs a logic 1 on a given GPIO
end

define set_gpio_low
    if $argc != 2
        printf "BOO! HISS! Try \"help set_gpio_low\"\n"
    else
        printf "INFO : setting GPIO%0d.%0d low.\n", $arg0, $arg1

        if $arg0 == 0
            # GPIO0 variables
            set variable $gpio_en0   = 0x40008000
            set variable $gpio_en1   = 0x40008068
            set variable $gpio_en2   = 0x40008074
            set variable $gpio_outen = 0x4000800C
            set variable $gpio_out   = 0x40008018
            set variable $gpio_inen  = 0x40008030
        else
            # GPIO1 variables
            set variable $gpio_en0   = 0x40009000
            set variable $gpio_en1   = 0x40009068
            set variable $gpio_en2   = 0x40009074
            set variable $gpio_outen = 0x4000900C
            set variable $gpio_out   = 0x40009018
            set variable $gpio_inen  = 0x40009030
        end

        set *$gpio_outen |=  (0x1 << $arg1)
        set *$gpio_en0   |=  (0x1 << $arg1)
        set *$gpio_en1   &= ~(0x1 << $arg1)
        set *$gpio_en2   &= ~(0x1 << $arg1)
        set *$gpio_inen  &= ~(0x1 << $arg1)
        set *$gpio_out   &= ~(0x1 << $arg1)

    end
end
document set_gpio_low
    usage:
    set_gpio_low <port number> <pin number>

    outputs a logic 0 on a given GPIO
end