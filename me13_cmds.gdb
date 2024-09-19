
#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME13 Area
#***************************************************************************
#***************************************************************************
#***************************************************************************

# BEGIN REGISTER DEFINITIONS #
set variable $PMR       = 0x4000000C
set variable $NFCLDOCTL = 0x40000074
set variable $BBSIR14   = 0x40005438
set variable $BB_TMR0   = 0x40005C00
set variable $BB_TMR2   = 0x40005C08
set variable $INTSCN    = 0x40004004
set variable $SECALM    = 0x40004008
set variable $SECDIAG   = 0x4000400C
# END REGISTER DEFINITIONS #

define unlock_otp
    # First, put flash controller in known lock state.
    lock_otp
    # Write acntl to unlock OTP on me13b
    set *$fctl_acntl=0xEEDC03D4
    set *$fctl_acntl=0xB5CF2888
    set *$fctl_acntl=0xB22E24B4
end

define write_dev_crk
    # Development CRK signed with ME13 production MRK
    unlock_otp
    # CRK
    write_flash_128 0x00081000 0x11d4296f 0x243cc2e4 0x1d47b46e 0x797b799f
    write_flash_128 0x00081010 0x52903f65 0x162e780a 0xc6778e36 0x78c697cf
    write_flash_128 0x00081020 0xe78e8c5a 0x709da100 0xddce3092 0x42f4a8f5
    write_flash_128 0x00081030 0x47193bc7 0x10e999c7 0x310cef65 0x21ede046
    write_flash_128 0x00081040 0xa5183b4b 0x6df913bd 0x00007f47 0x00000000
    # CRK Signature
    write_flash_128 0x00081060 0x90817a7a 0x100e0abe 0xc6fe53ad 0x4ac74df7
    write_flash_128 0x00081070 0xb3dc4e9b 0x83711303 0xf81c3d17 0x018819ac
    write_flash_128 0x00081080 0xf8bc4b4f 0x1c7addcc 0x0fb09f8b 0x553248a5
    write_flash_128 0x00081090 0x225e7245 0xa3233fa3 0x4c87376a 0x37756d04
    write_flash_128 0x000810A0 0x7ac2c895 0xcbc4122c 0x00005a1b 0x00000000
    lock_otp
end

# CAREFUL WITH THIS!: ME13 Write USN and other stuff test writes in during production
define write_rom_basics
    unlock_otp
    # Write USN
    write_flash_128 0x00080000 0x80028000 0x00f7e6d5 0x00800000 0x7b66d581
    write_flash_128 0x00080010 0x00570000 0x00000000 0xffffffff 0xffffffff

    # Write FMV (0x10, 0xff in lower words where USN is located, pattern in 0x18)
    write_flash_128 0x00080010 0xffffffff 0xffffffff 0x5a5aa5a5 0x5a5aa5a5
    # Write FTM
    write_flash_128 0x00080020 0x5a5aa5a5 0x5a5aa5a5 0xffffffff 0xffffffff
    # Write TM (0x20, 0xff in lower words where FTM is located, pattern in 0x28)
    write_flash_128 0x00080020 0xffffffff 0xffffffff 0x5a5aa5a5 0x5a5aa5a5

    # Write LCP5 Pattern #1
    write_flash_128 0x00080040 0x00001246 0x59455305 0x00000000 0x80000000
    # Write LCP5 Pattern #2
    write_flash_128 0x00080050 0x00001246 0x59455305 0x00000000 0x80000000

    # Write IPO Override Word (set to 48MHz for emulator) (offset 0xB0)
    # write_flash_128 0x000800B0 0x36007629 0x0000016e 0x00000000 0x00000000
    # Write IPO Override Word (set to 100MHz) (offset 0xB0)
    # write_flash_128 0x000800B0 0xf0804696 0x000002fa 0x00000000 0x00000000
    # Write IBRO Override Word (set to 7.3728MHz) (offset 0xC0)
    # write_flash_128 0x000800C0 0x40006e0a 0x00000038 0x00000000 0x00000000

    x/10x 0x10800000
    lock_otp
end

define measure_btm_bg
    # enter testmode
    tm_enable

    # Write 0x0000_0001 to BB_TMR2
    set *$BB_TMR2 = 0x00000001
    # Write 0x0000_0018 to BB_TMR0
    set *$BB_TMR0 = 0x00000018

    printf "INFO : VBG can then be measured between ABUS pin 0 and ABUS pin 2\n"
end
document measure_btm_bg
    Enters testmode, then writes necesary battery-backed
    testmode registers to bring out the bandgap voltages
end

define measure_vy_lt2
    # enter testmode
    tm_enable

    # Read BBSIR14
    # Copy bits 6 to bit 11 from the previously ready BBSIR14, and write them to bits 0 to 5 of BBSIR 14.
    # (this is a strange, known bug. All VY voltages use the LT1 trim location for measuring, but the correct locations are actually used by the BT monitor.)
    set variable $temp_val = (*$BBSIR14 & (0x3F << 6)) >> 6
    set *$BBSIR14 = (*$BBSIR14 & ~(0x3F << 0)) | ($temp_val << 0)

    # Write 0x0000_0023 to BB_TMR2
    set *$BB_TMR2 = 0x00000023
    # Write 0x0000_0018 to BB_TMR0
    set *$BB_TMR0 = 0x00000018

    printf "VY_LT2 can then be measured between ABUS pin 1 and ABUS pin 2\n"
end
document measure_vy_lt2
    Enters testmode, then writes necesary battery-backed
    testmode registers to bring out the VY_LT2
end

define check_btm_tripped
    if (*$INTSCN & ((0x1 << 16) | (0x1 << 7) | (0x1 << 1))) != ((0x1 << 16) | (0x1 << 7) | (0x1 << 1))
        # enter testmode
        tm_enable

        # Write 0x0000_0001 to BB_TMR2
        set *$BB_TMR2 = 0x00000001
        # Write 0x0000_0000 to BB_TMR0
        set *$BB_TMR0 = 0x00000000

        # To measure the LT2 trip point, make sure you don't have any of the above test modes set.
        # Set bits 16, 7, and 1 of the INTSCN register.
        set *$INTSCN |= (0x1 << 16) | (0x1 << 7) | (0x1 << 1)
        printf "INFO : INTSCN register wasn't already configured, run function again...\n"
    else
        # When tripped, TAMPER_O will go high, and bit 3 of SECALM register will be set to 1. Bit 3 of SECDIAG register will also be set when it trips.
        set variable $tripped = (*$SECDIAG & (0x1 << 3)) >> 3

        if $tripped == 0x1
            printf "INFO : BT Monitor Tripped\n"
        else
            printf "INFO : BT Monitor NOT Tripped\n"
        end
    end
end
document check_btm_tripped
    1. Enters testmode, then writes necesary battery-backed
       testmode registers to disable analog testmodes

    2. sets the INTSCN register to enable low-temp trigger

    3. read bit 3 of the SECDIAG register to determine if BT Monitor is tripped
end

define setup_vbat_trip
    tm_enable

    printf "WARNING : Ensure VBAT is between 2.4V and 3.63V before testing...\n"

    # Write 0x0000_0001 to BB_TMR2
    set *$BB_TMR2 = 0x00000001
    # Write 0x0000_0004 to INTSCN register
    set *$INTSCN = 0x00000004
    # Write 0x0000_0000 to SEC_SECALM register
    set *$SECALM = 0x00000000

    printf "INFO : Device configured for VBAT Trip point testing, run 'check_vbat_trip' to check status\n"

    check_vbat_trip
end

define check_vbat_trip
    if (*$SECALM & ((0x1 << 6) | (0x1 << 5))) == 0
        printf "INFO : OV and UV alarm NOT set\n"
    else
        # Bit 5 indicates VBAT UV has been tripped. Target voltage is 2.2v
        if (*$SECALM & (0x1 << 5)) == (0x1 << 5)
            printf "INFO : Under-Voltage alarm set\n"
        end

        # Bit 6 indicates VBAT OV has been tripped. Target voltage is 3.7v
        if (*$SECALM & (0x1 << 6)) == (0x1 << 6)
            printf "INFO : Over-Voltage alarm set\n"
        end
    end
end

define enable_0p9v_ldo
    # set bit 0 of the LDOCN register
    set *0x40006C60 |= 0x1
end

define disable_0p9v_ldo
    # clear bit 0 of the LDOCN register
    set *0x40006C60 &= ~(0x1)
end

define clear_power_monster
    power_monster

    # writing 1 to all bits that are set
    set *0x40006C64 |= *0x40006C64

    power_monster
end

define power_monster
    # read the PWRMONSTR (power monitor status register)
    x 0x40006C64
end

define init_USB
    set *0x400B1000 = 0
end

define enable_USB_PCLK
    set *0x40000024 &= ~0x8
end

define disable_USB_PCLK
    set *0x40000024 |= 0x8
end

define clear_USB_RST
    set *0x400B1410 &= 0x0
end

define configure_USB
    enable_0p9v_ldo
    enable_USB_PCLK
    clear_USB_RST

    # bit 0 -> suspend operation
    # bit 1 -> suspend the USBHS PHY
    set *0x400B14A0 = 0x3
end

define toggle_XTAL_BP
    x $PMR
    set *$PMR ^= (0x1 << 20)
    x $PMR
end

define toggle_NFCLDOCTRL_PD
    x $NFCLDOCTL
    set *$NFCLDOCTL ^= (0x1 << 5)
    x $NFCLDOCTL
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