set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off
set print elements 0

define ms
    monitor shutdown
end

define mh
    monitor halt
end

define tr3
    target remote: 3333
end

define tr4
    target remote: 3334
end

define mrh
    monitor reset halt
end

define hlc
    monitor reset halt
    load
    c
end

define dump_rvregs
    printf "RISC-V registers \n"
    set variable $base=0xE50707C0
    print "PC"
    x/x $base
    print "x1_ra"
    x/x $base+0x04
    print "x2_sp"
    x/x $base+0x08
    print "x3_gp"
    x/x $base+0x0c
    print "x4_tp"
    x/x $base+0x10
    print "x5_t0"
    x/x $base+0x14
    print "x6_t1"
    x/x $base+0x18
    print "x7_t2"
    x/x $base+0x1c
    print "x8_s0_fp"
    x/x $base+0x20
    print "x9_s1"
    x/x $base+0x24
    print "x10_a0"
    x/x $base+0x28
    print "x11_a1"
    x/x $base+0x2c
    print "x12_a2"
    x/x $base+0x30
    print "x13_a3"
    x/x $base+0x34
    print "x14_a4"
    x/x $base+0x38
    print "x15_a5"
    x/x $base+0x3c
    print "x16_a6"
    x/x $base+0x40
    print "x17_a7"
    x/x $base+0x44
    print "x18_s2"
    x/x $base+0x48
    print "x19_s3"
    x/x $base+0x4c
    print "x20_s4"
    x/x $base+0x50
    print "x21_s5"
    x/x $base+0x54
    print "x22_s6"
    x/x $base+0x58
    print "x23_s7"
    x/x $base+0x5c
    print "x24_s8"
    x/x $base+0x60
    print "x25_s9"
    x/x $base+0x64
    print "x26_s10"
    x/x $base+0x68
    print "x27_s11"
    x/x $base+0x6c
    print "x28_t3"
    x/x $base+0x70
    print "x29_t4"
    x/x $base+0x74
    print "x30_t5"
    x/x $base+0x78
    print "x31_t6"
    x/x $base+0x80
end
document dump_rvregs
    dump RISC-V registers
    USAGE: dump_rvregs
end

define loadcmrv
    if $argc == 0
        printf "BOO! HISS! Try \"help loadcmrv\"\n"
    else
        echo Loading: default binary \n
        load
        echo Loading: $arg0 \n
        load $arg0
        compare-sections
    end
end
document loadcmrv
    Load two cores with one load cmd
    USAGE: loadcmrv <path to rv elf>
end

define loadboth
    if $argc == 0
        printf "BOO! HISS! Try \"help loadboth\"\n"
    else
        echo \n Symbol file $arg0 \n\n
        monitor reset halt
        exec-file combined.elf
        echo \n Loading: combined binary \n\n
        load
        echo \n Loading symbols: $arg0 \n\n
        file $arg0
        compare-sections
        set $pc=Reset_Handler
    end
end
document loadboth
    Load two cores and arm symbols with one load cmd
    USAGE: loadboth <path to cm3 elf>
end

define loadbothplus
    if $argc < 2
        printf "BOO! HISS! Try \"help loadbothplus\"\n"
    else
        echo \n Symbol file $arg0 \n\n
        monitor reset halt
        exec-file $arg1
        echo \n Loading: combined binary \n\n
        load
        echo \n Loading symbols: $arg0 \n\n
        file $arg0
        compare-sections
        set $pc=Reset_Handler
    end
end
document loadbothplus
    Load two cores and arm symbols with one load cmd
    USAGE: loadbothplus <path to cm3 elf> <path to combined file>
end

define loadboth78000
    if $argc == 0
        printf "BOO! HISS! Try \"help loadboth\"\n"
    else
        monitor reset halt
        exec-file build/max78000-combined.elf
        echo Loading: combined binary \n
        load
        echo Loading symbols: $arg0 \n
        file $arg0
        compare-sections
    end
end
document loadboth78000
    Load two cores and arm symbols with one load cmd
    USAGE: loadboth <path to cm3 elf>
end

define except
    printf "Exception Stack UF/BF/MMSR\n"
    x/16x $sp-0x020
    printf "\nException Registers\n"
    x/16 0xE000ED28
end

define go
    target remote :3333
    monitor reset halt
    set $pc=Reset_Handler
    print $pc
    print $sp
    printf "Done\n"
end

define doload
    load
    compare-sections
end

define dumpinfo
    unlock_otp
    x/128wx 0x10800000
end
document dumpinfo
    Unlocks the OTP the dumps 128 words starting at 0x1080_0000
end

define erase
    monitor max32xxx mass_erase 0
end

define erase128
    monitor maxim128 mass_erase 0
end

define set_SRT_bit
  tm_enable
  set *0x40000c00 |= 0x00000020
end

define reset
    monitor halt
    monitor reset halt
    set $pc=Reset_Handler
    print $pc
    print $sp
    printf "Done\n"
end

#define armex
#  printf "EXEC_RETURN (LR):\n",
#  info registers $lr
#    if $lr & 0x4 == 0x4
#    printf "Uses MSP 0x%x return.\n", $MSP
#    set $armex_base = $MSP
#    else
#    printf "Uses PSP 0x%x return.\n", $PSP
#    set $armex_base = $PSP
#    end
#
#    printf "xPSR            0x%x\n", *($armex_base+28)
#    printf "ReturnAddress   0x%x\n", *($armex_base+24)
#    printf "LR (R14)        0x%x\n", *($armex_base+20)
#    printf "R12             0x%x\n", *($armex_base+16)
#    printf "R3              0x%x\n", *($armex_base+12)
#    printf "R2              0x%x\n", *($armex_base+8)
#    printf "R1              0x%x\n", *($armex_base+4)
#    printf "R0              0x%x\n", *($armex_base)
#    printf "Return instruction:\n"
#    x/i *($armex_base+24)
#    printf "LR instruction:\n"
#    x/i *($armex_base+20)
#end
#
#document armex
#ARMv7 Exception entry behavior.
#xPSR, ReturnAddress, LR (R14), R12, R3, R2, R1, and R0
#end
set variable $gcr_base_addr=0x40000000
set variable $scon_addr=$gcr_base_addr+0

set variable $fctl_base_addr=0x40029000
set variable $fctl_faddr=$fctl_base_addr+0x00
set variable $fctl_fckdiv=$fctl_base_addr+0x04
set variable $fctl_fcntl=$fctl_base_addr+0x08
set variable $fctl_acntl=$fctl_base_addr+0x40
set variable $fctl_fdata0=$fctl_base_addr+0x30
set variable $fctl_fdata1=$fctl_base_addr+0x34
set variable $fctl_fdata2=$fctl_base_addr+0x38
set variable $fctl_fdata3=$fctl_base_addr+0x3C

define es17
    tr3
    source ~/gdb/es17_cmds.gdb
    mh
end

define me13
    tr3
    source ~/gdb/me13_cmds.gdb
    mh
end

define me15
    tr3
    source ~/gdb/me15_cmds.gdb
    mh
end

define me21
    tr3
    source ~/gdb/me21_cmds.gdb
    mh
end

define me55
    tr3
    source ~/gdb/me55_cmds.gdb
    mh
end

define tm_enable
    # enable testmode
    set *0x40000c00=*0x40000c00 | 0x00000001
    check_tm
end

define check_tm
    # read the TMR
    x 0x40000c00
end

define lock_otp
    # Write acntl to lock OTP
    set *$fctl_acntl=0xdeadbeef
end

# arg0 = address
# arg1 = 32-bit data
define write_flash
    # Unlock and Set width to 32 (bit 4 to one)
    set *$fctl_fcntl=0x20000010
    set *$fctl_faddr=$arg0
    set *$fctl_fdata0=$arg1
    set *$fctl_fcntl=0x20000011
end

define enable_IPO_tclk
    setup_tclk_output 0x02 0xF
end

define enable_USB_tclk
    setup_tclk_output 0x0D 0xF
end

define setup_tclk_output
    if $argc != 2
        printf "BOO! HISS! Try \"help setup_tclk_output\"\n"
    else
        # set TME bit
        tm_enable

        # disable the TCLK output
        set *0x40000C08 &= ~(0x1 << 15)

        printf "INFO : enabling the test clock with selection of 0x%0x and divide ratio of 0x%0x\n", $arg0, $arg1

        # set 0x2 for IPO, 0xF << 8 for divide-by-15
        set *0x40000C08 = ($arg0 << 0) | ($arg1 << 8)

        # enable the TCLK output
        set *0x40000C08 |= (0x1 << 15)
    end
end

# arg0 = address
# arg1 = 32-bit data
# arg2 = 32-bit data
# arg3 = 32-bit data
# arg4 = 32-bit data
define write_flash_128
    # # Set flash clock divide to 20
    # set *$fctl_fckdiv=20

    # Unlock and Set width to 128 (bit 4 to zero)
    set *$fctl_fcntl=*$fctl_fcntl | 0x20000000
    set *$fctl_fcntl=*$fctl_fcntl & ~0x00000010

    # Set address
    set *$fctl_faddr=$arg0

    # Set 128-bits of data
    set *$fctl_fdata0=$arg1
    set *$fctl_fdata1=$arg2
    set *$fctl_fdata2=$arg3
    set *$fctl_fdata3=$arg4

    # start flash operation
    set *$fctl_fcntl |= 0x20000001
end

define check_ECC_ERR
    print "INFO : Reading the value in the ECC Error Register..."
    x $ECC_ERR_ADDR
    print "INFO : Reading the value in the ECC Error Address Register..."
    x $ECC_ERR_ADDR_ADDR
end
document check_ECC_ERR
    Prints the values related to an ECC Error
end

define clear_FLASH_ECC_ERR
    print "INFO : Reading the value in the ECC Error Register..."
    x $ECC_ERR_ADDR
    print "INFO : Clearing the FLASH ECC ERROR flag..."
    set *$ECC_ERR_ADDR = 0x10
    print "INFO : Reading the value in the ECC Error Register..."
    x $ECC_ERR_ADDR
end
document clear_FLASH_ECC_ERR
    Clears the Flash0 ECC Error flag in GCR
end

define read_FLASH_ECC_DATA
    check_ECC_ERR
    print "INFO : Reading data to catch the ECC values..."
    x/64x 0x10000000
    print "INFO : Reading the ECC value used on the last read:"
    x $ECC_DATA_ADDR
    check_ECC_ERR
end
document read_FLASH_ECC_DATA
    Prints the value in the flash ECC Data register
end

define enable_FLASH_ECC
    set *$ECC_ADDR=*$ECC_ADDR | 0x00001000
    read_FLASH_ECC_DATA
end
document enable_FLASH_ECC
    Set the Flash0 ECC Enable bit
end

define disable_FLASH_ECC
    set *$ECC_ADDR=*$ECC_ADDR & 0xFFFFEFFF
    read_FLASH_ECC_DATA
end
document disable_FLASH_ECC
    Clear the Flash0 ECC Enable bit
end

define test_flash_128
    print "Base address: $base"
    write_flash_128 $base+0x000 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x010 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x020 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x030 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x040 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x050 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x060 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x070 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x080 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x090 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x0a0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x0b0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x0c0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x0d0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x0e0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x0f0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x100 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x110 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x120 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x130 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x140 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x150 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x160 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x170 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x180 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x190 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x1a0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x1b0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x1c0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x1d0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x1e0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x1f0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x200 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x210 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x220 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x230 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x240 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x250 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x260 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x270 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x280 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x290 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x2a0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x2b0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x2c0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x2d0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x2e0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x2f0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x300 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x310 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x320 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x330 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x340 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x350 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x360 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x370 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x380 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x390 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x3a0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x3b0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x3c0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x3d0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x3e0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    write_flash_128 $base+0x3f0 0x12345678 0x9abcdef0 0x11223344 0x55667788
    x $base+0x10004000
    x/256x $base+0x10000000
end
