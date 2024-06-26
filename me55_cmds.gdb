
#***************************************************************************
#***************************************************************************
#***************************************************************************
# ME55 Area
#***************************************************************************
#***************************************************************************
#***************************************************************************

# BEGIN REGISTER DEFINITIONS #
set variable $BBSIR14 = 0x40005438
set variable $BB_TMR0 = 0x40005C00
set variable $BB_TMR2 = 0x40005C08
set variable $INTSCN  = 0x40004004
set variable $SECALM  = 0x40004008
set variable $SECDIAG = 0x4000400C
# END REGISTER DEFINITIONS #

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