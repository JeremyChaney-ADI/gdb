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

define me10_write_usb_enable_on2p7_otp
    unlock_otp
    write_flash 0x10800050 0xd3ff8f10
    write_flash 0x10800054 0x7fffffff
    x/2x 0x10800050
    lock_otp
end
document me10_write_usb_enable_on2p7_otp
    ME10 Enable USB bootloader on P2.7=1
end

define me10_write_uart_enable_on2p7_otp
    unlock_otp
    write_flash 0x10800050 0xffd3b561
    write_flash 0x10800054 0x7fffffff
    x/2x 0x10800050
    lock_otp
end
document me10_write_uart_enable_on2p7_otp
    ME10 Enable UART bootloader on P2.7=1
end

define me10_write_usb_enable_on1p0_low_otp
    unlock_otp
    write_flash 0x10800050 0xa07f9f09
    write_flash 0x10800054 0x7fffffff
    x/2x 0x10800050
    lock_otp
end
document me10_write_usb_enable_on1p0_low_otp
    ME10 Enable USB bootloader on P1.0=0
end


define me10_write_HIRC96_override_80Mhz
    unlock_otp
    write_flash 0x10800078 0x5a007cc5
    write_flash 0x1080007c 0x00000262
    x/100x 0x10800000
    lock_otp
end
document me10_write_HIRC96_override_80Mhz
    ME10 Set HIRC96 frequency to 80MHz (for emulator at 40 MHz with PSC set to DIV2)
end

define me10_write_HIRC96_override_40Mhz
    unlock_otp
    write_flash 0x10800078 0x2d00229f
    write_flash 0x1080007c 0x00000131
    x/100x 0x10800000
    lock_otp
end
document me10_write_HIRC96_override_40Mhz
    ME10 Set HIRC96 frequency to 40MHz (for emulator at 20 MHz with PSC set to DIV2)
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

define max32651_write_dev_crk
    unlock_otp

    # Development CRK
    write_flash_128 0x10801000 0x726d6084 0x056efb1c 0x765d53c0 0x76e2d04f
    write_flash_128 0x10801010 0x517d357e 0x3534d883 0x742ac307 0x0f0dead5
    write_flash_128 0x10801020 0xedcffd01 0x024cc0b3 0xe1895e24 0x0fb7c9a7
    write_flash_128 0x10801030 0xfd1f719e 0x55146fb0 0xf3ec5cdb 0x4eaaafe3
    write_flash_128 0x10801040 0x2a21b900 0x4b7c040e 0xa900a289 0x02cfbe38
    write_flash_128 0x10801050 0x754e7b05 0x527a9c50 0xe29f1f4d 0x3a68b15e
    write_flash_128 0x10801060 0x21822b53 0x4c0c93c7 0x7764c181 0x02394185
    write_flash_128 0x10801070 0x3c225800 0x4450f98c 0x6a4b742c 0x13fe6731
    write_flash_128 0x10801080 0x193a8e60 0x3dee4577 0x0617398b 0x7dacfad4
    write_flash_128 0x10801090 0x29c574e9 0x686d75a0 0xf3984dd8 0x25ab4d21
    write_flash_128 0x108010a0 0x5667caac 0x2b7490ea 0x35c9765c 0x6fe69eef
    write_flash_128 0x108010b0 0x16567691 0x5161b34b 0x5cfe987d 0x0ddf8331
    write_flash_128 0x108010c0 0x1b1da6e0 0x0a51d37d 0x0eec4452 0x1c57aa10
    write_flash_128 0x108010d0 0x836b87bf 0x6266225e 0x7ad71672 0x3aa84b95
    write_flash_128 0x108010e0 0xd68f08c1 0x10e456c5 0xd1e1db78 0x0b29f89a
    write_flash_128 0x108010f0 0x9e196ddd 0x5ce7bf83 0x0b33e94c 0x106f0728
    write_flash_128 0x10801100 0xdc5de74f 0x36716a0f 0xa9b0170b 0x2ffa5899
    write_flash_128 0x10801110 0xbaa950c7 0x158cc6a9 0xc09a5d95 0x3e7c55f5
    write_flash_128 0x10801120 0xabcf6c5c 0x7afbbdaf 0x6eff03dd 0x2869e801
    write_flash_128 0x10801130 0xe58888b8 0x44242e06 0x4506ebc3 0x540304bd
    write_flash_128 0x10801140 0x7ddb3ec4 0x50878f64 0x4f81b5c4 0x78d5e613
    write_flash_128 0x10801150 0xe49e7d21 0x000002c1 0x00001715 0x00000000
    write_flash_128 0x10801160 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801170 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801180 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801190 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108011a0 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108011b0 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108011c0 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108011d0 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108011e0 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108011f0 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801200 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801210 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801220 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801230 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801240 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801250 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801260 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801270 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801280 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x10801290 0x00001715 0x00000000 0x00001715 0x00000000
    write_flash_128 0x108012a0 0x00001715 0x00000000 0x00001715 0x00000000

    # CRK Key Length, Exponent, Exponent Length
    write_flash 0x108012b0 0x00020d1e
    write_flash 0x108012b4 0x00800080

    # CRK Signature
    write_flash 0x108012b8 0xae32045a
    write_flash 0x108012bc 0x6b8488b1
    write_flash_128 0x108012c0 0x71dee561 0x11cb88bf 0xb2d72f80 0x528cc237
    write_flash_128 0x108012d0 0xe0f8d6e9 0x7f52b2b1 0xb24e9b8a 0x3eed1827
    write_flash_128 0x108012e0 0x21597c3c 0x1b0d5066 0x8eaa400e 0x05fb93fc
    write_flash_128 0x108012f0 0x12b07e7e 0x03bcce07 0x0146b70c 0x4f33b979
    write_flash_128 0x10801300 0xb8cf927e 0x0c43321f 0x7a4d588c 0x205127fc
    write_flash_128 0x10801310 0x9c6587d9 0x100800bd 0x85d555c7 0x7113501f
    write_flash_128 0x10801320 0xe459857a 0x364c66e4 0xff840dce 0x4e2aacb2
    write_flash_128 0x10801330 0xc1c6ef7f 0x6c560b50 0x8fe43d84 0x78ab457e
    write_flash_128 0x10801340 0x15e0f586 0x7c413821 0x1592f5e2 0x51f0c059
    write_flash_128 0x10801350 0x27ed626a 0x3eae4a8b 0xafa48842 0x0b447568
    write_flash_128 0x10801360 0xc9880310 0x7b98d6c6 0xf63e5068 0x244445d1
    write_flash_128 0x10801370 0x388e98b5 0x7718e941 0x0ee229f6 0x419ec436
    write_flash_128 0x10801380 0xb9b3d9e0 0x7c9b2382 0x10bcdaa6 0x3d2b91f6
    write_flash_128 0x10801390 0x5ed4dd50 0x3d94201a 0xe4ce71f6 0x72691266
    write_flash_128 0x108013a0 0xc6efa145 0x0b7b368f 0x948bf209 0x03fb0148
    write_flash_128 0x108013b0 0x3c3deb3e 0x74c750f5 0x68eebd5e 0x5f59f923
    write_flash_128 0x108013c0 0xf71b42a8 0x0b05b2f8 0x9c65f160 0x345e9c52
    write_flash_128 0x108013d0 0x4391d2b4 0x1d1d712b 0x3b7dec75 0x5ed21a4a
    write_flash_128 0x108013e0 0xfe724571 0x368b4466 0xa40bc341 0x61d2b74a
    write_flash_128 0x108013f0 0xf00f86c1 0x4e39623a 0x454433ed 0x2ac67736
    write_flash_128 0x10801400 0xbafe2fa1 0x37a25028 0x805fba3d 0x27baa6c9
    write_flash_128 0x10801410 0x04be763b 0x12a3492c 0x9e91acc5 0x4018e3f3
    write_flash_128 0x10801420 0x610a78d7 0x18167a30 0x5b32b764 0x2d3a7a44
    write_flash_128 0x10801430 0x69e0f3bd 0x001f57dd 0x14d17d88 0x6e7589aa
    write_flash_128 0x10801440 0xfd2b8424 0x76a9d19e 0x1ebdc3df 0x07461b6e
    write_flash_128 0x10801450 0x56203a3d 0x7fcd1d1c 0x838fdf41 0x02fcb69d
    write_flash_128 0x10801460 0x70a3d985 0x1772936d 0x34a45d9b 0x4f1ccd6b
    write_flash_128 0x10801470 0xc7e0e9d2 0x4d754e7a 0xebb26cb0 0x6af7e671
    write_flash_128 0x10801480 0x6faa7b30 0x7cdf3640 0xdc6fceec 0x03dbbce9
    write_flash_128 0x10801490 0x658ace49 0x5f28f45a 0x8b49f69a 0x2f2219df
    write_flash_128 0x108014a0 0x44c81967 0x1c0ca466 0x4c036796 0x59818007
    write_flash_128 0x108014b0 0x5cecfa39 0x7ab126ea 0x0c895037 0x6091544b
    write_flash_128 0x108014c0 0xe42cf68a 0x51e82770 0x084e88a3 0x745973d9
    write_flash_128 0x108014d0 0x0c201156 0x68b3ae1e 0xb759f84f 0x4ae56268
    write_flash_128 0x108014e0 0x61ec3441 0x2893538a 0x78619363 0x467fa8d4
    write_flash_128 0x108014f0 0x55f0b5de 0x6452ecb2 0xbb733b95 0x59075baf
    write_flash_128 0x10801500 0x2cb17c72 0x4bbc8888 0xd16b3117 0x1925a758
    write_flash_128 0x10801510 0x44690633 0x188af31c 0xb4e9216a 0x7ed71751
    write_flash_128 0x10801520 0x2a94bf39 0x2a144e4e 0xfd8cc09f 0x335d47a1
    write_flash_128 0x10801530 0xf231be45 0x411f0a1c 0x52d6a93a 0x0276f4e8
    write_flash_128 0x10801540 0x5effca3e 0x7f74fa50 0xf50c2d0f 0x75bb675e
    write_flash_128 0x10801550 0xc1f456f7 0x5b1a6bf0 0xcffe6eae 0x2cb7b3a0
    write_flash 0x10801560 0x37853538
    write_flash 0x10801564 0x00000000

    lock_otp
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
    lock_otp
    me10_otp_smartdump
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