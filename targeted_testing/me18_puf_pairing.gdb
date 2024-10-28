
# default number of times a test runs when using the *suite* functions
set variable $test_count_limit_default = 100

set variable $dump_passing_puf_data = 0

# change this to be the location in SRAM where the dut_fail variable is held.
set variable $dut_fail_addr = 0x200635F0
set variable $puf_elem_addr = 0x20061000

# variables used to keep track of the results as well as debug failure causes
set variable $multi_test_run                = 0
set variable $num_puf_pairing_tests         = 0
set variable $num_puf_pairing_tests_pass    = 0
set variable $num_puf_pairing_tests_fail    = 0
set variable $num_puf_pairing_tests_fail_01 = 0
set variable $num_puf_pairing_tests_fail_02 = 0
set variable $num_puf_pairing_tests_fail_03 = 0
set variable $num_puf_pairing_tests_fail_04 = 0
set variable $num_puf_pairing_tests_fail_05 = 0
set variable $num_puf_pairing_tests_fail_06 = 0
set variable $num_puf_pairing_tests_fail_07 = 0
set variable $num_puf_pairing_tests_fail_08 = 0
set variable $num_puf_pairing_tests_fail_09 = 0
set variable $num_puf_pairing_tests_fail_10 = 0
set variable $num_puf_pairing_tests_fail_11 = 0
set variable $num_puf_pairing_tests_fail_12 = 0
set variable $num_puf_pairing_tests_fail_13 = 0
set variable $num_puf_pairing_tests_fail_14 = 0
set variable $num_puf_pairing_tests_fail_15 = 0
set variable $num_puf_pairing_tests_fail_16 = 0
set variable $num_puf_pairing_tests_fail_17 = 0
set variable $num_puf_pairing_tests_fail_18 = 0

define decode_puf_pairing_error_code

    printf "INFO : Reading address 0x%x to determine pass/fail status", $dut_fail_addr
    set variable $dut_fail = *$dut_fail_addr
    if $dut_fail
        printf "\n===========\nFAIL with code 0x%0x\n", $dut_fail

        ########### DECODING THE ERROR CODES ###########

        if $dut_fail == 0x1
            set $num_puf_pairing_tests_fail_01 = $num_puf_pairing_tests_fail_01 + 1
        end

        if $dut_fail == 0x2
            set $num_puf_pairing_tests_fail_02 = $num_puf_pairing_tests_fail_02 + 1
        end

        if $dut_fail == 0x3
            set $num_puf_pairing_tests_fail_03 = $num_puf_pairing_tests_fail_03 + 1
        end

        if $dut_fail == 0x4
            set $num_puf_pairing_tests_fail_04 = $num_puf_pairing_tests_fail_04 + 1
        end

        if $dut_fail == 0x5
            set $num_puf_pairing_tests_fail_05 = $num_puf_pairing_tests_fail_05 + 1
        end

        if $dut_fail == 0x6
            printf "INFO : ADDR register non-zero\n"
            set $num_puf_pairing_tests_fail_06 = $num_puf_pairing_tests_fail_06 + 1
        end

        if $dut_fail == 0x7
            set $num_puf_pairing_tests_fail_07 = $num_puf_pairing_tests_fail_07 + 1
        end

        if $dut_fail == 0x8
            set $num_puf_pairing_tests_fail_08 = $num_puf_pairing_tests_fail_08 + 1
        end

        if $dut_fail == 0x9
            set $num_puf_pairing_tests_fail_09 = $num_puf_pairing_tests_fail_09 + 1
        end

        if $dut_fail == 0xA
            printf "INFO : dist_mean outside of acceptable range\n"
            set $num_puf_pairing_tests_fail_10 = $num_puf_pairing_tests_fail_10 + 1
        end

        if $dut_fail == 0xB
            printf "INFO : dist_stdev outside of acceptable range\n"
            set $num_puf_pairing_tests_fail_11 = $num_puf_pairing_tests_fail_11 + 1
        end

        if $dut_fail == 0xC
            printf "INFO : elem_sum_fail_count exceeded limit\n"
            set $num_puf_pairing_tests_fail_12 = $num_puf_pairing_tests_fail_12 + 1
        end

        if $dut_fail == 0xD
            printf "INFO : elem_delta_fail_count exceeded limit\n"
            set $num_puf_pairing_tests_fail_13 = $num_puf_pairing_tests_fail_13 + 1
        end

        if $dut_fail == 0xE
            set $num_puf_pairing_tests_fail_14 = $num_puf_pairing_tests_fail_14 + 1
        end

        if $dut_fail == 0xF
            set $num_puf_pairing_tests_fail_15 = $num_puf_pairing_tests_fail_15 + 1
        end

        if $dut_fail == 0x10
            printf "INFO : CTLR PUF-Enable not cleared\n"
            set $num_puf_pairing_tests_fail_16 = $num_puf_pairing_tests_fail_16 + 1
        end

        if $dut_fail == 0x11
            printf "INFO : flash_write_error_count was non-zero\n"
            set $num_puf_pairing_tests_fail_17 = $num_puf_pairing_tests_fail_17 + 1
        end

        if $dut_fail == 0x12
            printf "INFO : PUF pairs not present\n"
            set $num_puf_pairing_tests_fail_18 = $num_puf_pairing_tests_fail_18 + 1
        end
        ########### END DECODING THE ERROR CODES ###########

        printf "===========\n"
        puf_test_fail
    else
        printf "\n===========\nPASS\n===========\n"
        puf_test_pass
    end
end
document decode_puf_pairing_error_code
    Once PUF checking program has run, use this to decode the different error codes.
    Outputs a Pass/Fail along with a fail cause.
end

define dump_puf_data

    if $argc != 1
        printf "BOO! HISS! Try \"help dump_puf_data\"\n"
    else
        set $pass_fail = $arg0
        set logging file puf_data.txt
        set logging redirect on
        set logging on
        if $pass_fail
            printf "\nINFO : TEST #%0d PUF data below (PASSING):\n", $num_puf_pairing_tests
            if $dump_passing_puf_data
                x/2304 0x20061000
            else
                printf "\tNot printing PUF data for Passing tests\n"
            end
        else
            printf "\nINFO : TEST #%0d PUF data below (FAILING):\n", $num_puf_pairing_tests
            x/2304 0x20061000
        end
        set logging off
        set logging redirect off
    end
end
document dump_puf_data
    Writes out PUF data for a given test, also provides the PASSING/FAILING exit codes.
    To enable PUF data dumping for passing tests, set $dump_passing_puf_data to 1.
end

define puf_pairing_tests_reset_counts
    set $num_puf_pairing_tests         = 0
    set $num_puf_pairing_tests_pass    = 0
    set $num_puf_pairing_tests_fail    = 0
    set $num_puf_pairing_tests_fail_01 = 0
    set $num_puf_pairing_tests_fail_02 = 0
    set $num_puf_pairing_tests_fail_03 = 0
    set $num_puf_pairing_tests_fail_04 = 0
    set $num_puf_pairing_tests_fail_05 = 0
    set $num_puf_pairing_tests_fail_06 = 0
    set $num_puf_pairing_tests_fail_07 = 0
    set $num_puf_pairing_tests_fail_08 = 0
    set $num_puf_pairing_tests_fail_09 = 0
    set $num_puf_pairing_tests_fail_10 = 0
    set $num_puf_pairing_tests_fail_11 = 0
    set $num_puf_pairing_tests_fail_12 = 0
    set $num_puf_pairing_tests_fail_13 = 0
    set $num_puf_pairing_tests_fail_14 = 0
    set $num_puf_pairing_tests_fail_15 = 0
    set $num_puf_pairing_tests_fail_16 = 0
    set $num_puf_pairing_tests_fail_17 = 0
    set $num_puf_pairing_tests_fail_18 = 0
end

define puf_test_fail
    set $num_puf_pairing_tests = $num_puf_pairing_tests + 1
    set $num_puf_pairing_tests_fail = $num_puf_pairing_tests_fail + 1

    # to avoid false failures due to code execution getting corrupted, this will hold up code unless the 'fail' path is actually taken
    # only do this when running more than 1 test at a time
    if $multi_test_run
        tbreak MXC_GPIO_OutClr
        c
    end

    # dump the PUF data with 'failing' code
    dump_puf_data 0
end
document puf_test_fail
    Run this function when a PUF test fails to increment the fail count.
end

define puf_test_pass
    set $num_puf_pairing_tests = $num_puf_pairing_tests + 1
    set $num_puf_pairing_tests_pass = $num_puf_pairing_tests_pass + 1

    # to avoid false pass due to code execution getting corrupted, this will hold up code unless the 'pass' path is actually taken
    # only do this when running more than 1 test at a time
    if $multi_test_run
        tbreak MXC_GPIO_OutSet
        c
    end

    # dump the PUF data with 'passing' code
    dump_puf_data 1
end
document puf_test_pass
    Run this function when a PUF test passes to increment the pass count.
end

define run_puf_pairing_test_change_psc
    if $argc != 1
        printf "BOO! HISS! Try \"help write_psc\"\n"
    else
        printf "INFO : CLKCN register before reset: "
        x 0x40000008
        mrh
        printf "INFO : CLKCN register after reset: "
        x 0x40000008

        # set a temporary break point at the first function call of main()
        tbreak main
        c

        write_psc $arg0

        # set a temporary break point at the point that the PUF is disabled and testing is finished
        tbreak puf_disable
        c

        decode_puf_pairing_error_code
    end
end
document run_puf_pairing_test_change_psc
    Resets the program, runs to a break point, writes a new prescalar value for the HCLK, and resumes
    Decodes the error code at puf_disable() function call

    To run multiple times in a row and report results at the end,
    use multi_run_puf_pairing_test_change_psc. ie:
    > help multi_run_puf_pairing_test_change_psc
end

define run_puf_pairing_test
    printf "INFO : CLKCN register before reset: "
    x 0x40000008
    mrh
    printf "INFO : CLKCN register after reset: "
    x 0x40000008

    # set a temporary break point at the point that the PUF is disabled and testing is finished
    tbreak puf_disable
    c

    decode_puf_pairing_error_code
end
document run_puf_pairing_test
    Resets the program, runs to a break point
    Decodes the error code at puf_disable() function call

    To run multiple times in a row and report results at the end,
    use multi_run_puf_pairing_test. ie:
    > help multi_run_puf_pairing_test
end

define print_puf_pairing_fail_cause

    if $num_puf_pairing_tests_fail_01
        printf "INFO : # of fails with code 01 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_01, (100 * $num_puf_pairing_tests_fail_01) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_02
        printf "INFO : # of fails with code 02 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_02, (100 * $num_puf_pairing_tests_fail_02) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_03
        printf "INFO : # of fails with code 03 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_03, (100 * $num_puf_pairing_tests_fail_03) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_04
        printf "INFO : # of fails with code 04 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_04, (100 * $num_puf_pairing_tests_fail_04) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_05
        printf "INFO : # of fails with code 05 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_05, (100 * $num_puf_pairing_tests_fail_05) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_06
        printf "INFO : # of fails with code 06 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_06, (100 * $num_puf_pairing_tests_fail_06) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_07
        printf "INFO : # of fails with code 07 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_07, (100 * $num_puf_pairing_tests_fail_07) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_08
        printf "INFO : # of fails with code 08 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_08, (100 * $num_puf_pairing_tests_fail_08) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_09
        printf "INFO : # of fails with code 09 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_09, (100 * $num_puf_pairing_tests_fail_09) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_10
        printf "INFO : # of fails with code 10 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_10, (100 * $num_puf_pairing_tests_fail_10) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_11
        printf "INFO : # of fails with code 11 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_11, (100 * $num_puf_pairing_tests_fail_11) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_12
        printf "INFO : # of fails with code 12 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_12, (100 * $num_puf_pairing_tests_fail_12) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_13
        printf "INFO : # of fails with code 13 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_13, (100 * $num_puf_pairing_tests_fail_13) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_14
        printf "INFO : # of fails with code 14 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_14, (100 * $num_puf_pairing_tests_fail_14) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_15
        printf "INFO : # of fails with code 15 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_15, (100 * $num_puf_pairing_tests_fail_15) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_16
        printf "INFO : # of fails with code 16 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_16, (100 * $num_puf_pairing_tests_fail_16) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_17
        printf "INFO : # of fails with code 17 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_17, (100 * $num_puf_pairing_tests_fail_17) / $num_puf_pairing_tests_fail
    end

    if $num_puf_pairing_tests_fail_18
        printf "INFO : # of fails with code 18 = %0d (%0d%% of total failures)\n", $num_puf_pairing_tests_fail_18, (100 * $num_puf_pairing_tests_fail_18) / $num_puf_pairing_tests_fail
    end
end
document print_puf_pairing_fail_cause
    output the breakdown of what caused different tests to fail
end

define multi_run_puf_pairing_test

    puf_pairing_tests_reset_counts

    if $argc == 1
        set $test_count_limit = $arg0
    else
        set $test_count_limit = $test_count_limit_default
    end

    set $multi_test_run = 1
    shell rm -f puf_data.txt

    set variable $idx = 0
    while ($idx < $test_count_limit)
        run_puf_pairing_test
        set $idx = $idx + 1
        printf "INFO : Finished Test %0d/%0d\n\n\n", $idx, $test_count_limit
    end

    set $multi_test_run = 0

    set logging file puf_data.txt
    set logging on
    printf "INFO : FINAL REPORT\n"
    printf "INFO : # of PUF tests PASS = %0d (%0d%% Passing)\n", $num_puf_pairing_tests_pass, (100 * $num_puf_pairing_tests_pass) / $num_puf_pairing_tests
    printf "INFO : # of PUF tests FAIL = %0d (%0d%% Failing)\n", $num_puf_pairing_tests_fail, (100 * $num_puf_pairing_tests_fail) / $num_puf_pairing_tests
    printf "INFO : # of PUF tests DONE = %0d\n\n", $num_puf_pairing_tests

    # output the breakdown of what caused different tests to fail
    if $num_puf_pairing_tests_fail
        printf "########### BREAKDOWN OF FAILURES BY ERROR CODE ###########\n\n"
        print_puf_pairing_fail_cause
        printf "\n########################### END ###########################\n\n"
    end
    set logging off
end
document multi_run_puf_pairing_test

    Runs a the PUF Pairing test $test_count_limit times and reports the number
    of times it passed/failed along with any fail reasons.

    Usage:
        1.  Runs the PUF pairing test the default number of times,
            check $test_count_limit_default for that value:
        > multi_run_puf_pairing_test

        2.  Runs the PUF pairing test the 500 times:
        > multi_run_puf_pairing_test 500
end

define multi_run_puf_pairing_test_change_psc

    if $argc < 1
        printf "BOO! HISS! Try \"help write_psc\"\n"
    else

        if $argc == 2
            set $test_count_limit = $arg1
        else
            set $test_count_limit = $test_count_limit_default
        end

        puf_pairing_tests_reset_counts

        set $multi_test_run = 1
        shell rm -f puf_data.txt

        set variable $idx = 0
        while ($idx < $test_count_limit)
            run_puf_pairing_test_change_psc $arg0
            set $idx = $idx + 1
            printf "INFO : Finished Test %0d/%0d\n\n\n", $idx, $test_count_limit
        end

        set $multi_test_run = 0

        set logging file puf_data.txt
        set logging on
        printf "INFO : FINAL REPORT\n"
        printf "INFO : Prescalar set to 0x%0x\n", $arg0
        printf "INFO : # of PUF tests PASS = %0d (%0d%% Passing)\n", $num_puf_pairing_tests_pass, (100 * $num_puf_pairing_tests_pass) / $num_puf_pairing_tests
        printf "INFO : # of PUF tests FAIL = %0d (%0d%% Failing)\n", $num_puf_pairing_tests_fail, (100 * $num_puf_pairing_tests_fail) / $num_puf_pairing_tests
        printf "INFO : # of PUF tests DONE = %0d\n\n", $num_puf_pairing_tests

        # output the breakdown of what caused different tests to fail
        if $num_puf_pairing_tests_fail
            printf "########### BREAKDOWN OF FAILURES BY ERROR CODE ###########\n\n"
            print_puf_pairing_fail_cause
            printf "\n########################### END ###########################\n\n"
        end
        set logging off
    end
end
document multi_run_puf_pairing_test_change_psc

    Runs a the PUF Pairing test $test_count_limit times and reports the number
    of times it passed/failed along with any fail reasons.
    ALSO CHANGES HCLK PRESCALAR.

    Usage:
        1.  Runs the PUF pairing test the default number of times with Prescalar set to 0x1,
            check $test_count_limit_default for that value:
        > multi_run_puf_pairing_test_change_psc 0x1

        2.  Runs the PUF pairing test the 500 times with Prescalar set to 0x1:
        > multi_run_puf_pairing_test_change_psc 0x1 500
end