// tb_cpu_suite.sv
// Top-level testbench for the RISC-V baseline suite.
//
// Architecture
// ============
//  - cpu_if          : interface connecting TB to DUT (clocking block + modports)
//  - cpu_test_pkg    : shared types, string utilities, constants
//  - yaml_loader     : module that reads baseline-suite.yaml and populates an
//                      array of test_descriptor_t structs
//  - cpu_suite_runner: program block that drives the interface and checks results
//  - tb_cpu_suite    : top module; instantiates clock, DUT, interface, and the
//                      above two blocks
//
// YAML parsing strategy
// =====================
// The parser is line-oriented.  It maintains a small state machine:
//   IDLE -> IN_TEST -> IN_EXPECTED -> IN_REGISTERS -> IN_MEMORY_WORDS
// It extracts only the fields it needs:
//   test_name, enabled, program_image, max_cycles,
//   registers (addr: hex_value pairs), memory_words (hex_addr: hex_value pairs)
// Lines that do not match any known key are ignored, which makes the parser
// tolerant of YAML comments, multi-line strings, and unknown fields.
//
// Register shadowing
// ==================
// Because RISC_V_02 only exposes the WB bus (one write per cycle), the runner
// maintains a 32-entry shadow register file.  Every cycle it checks the WB bus
// signals on the interface and updates the shadow copy.  At end-of-test the
// shadow is compared against the expected register values from the YAML.
//
// Memory checking
// ===============
// Memory words are read via hierarchical reference to the internal dmem array
// inside the DUT.  This is simulator-standard practice and avoids any RTL
// changes to the memory block.
//
// Usage
// =====
//   vcs  -sverilog -f tb/files.f -timescale 1ns/1ps +define+SUITE_YAML=\"...\"
//   xsim --sv --include tb/   (after elaboration)
//
// The YAML file path defaults to RISC_V/tests/specs/baseline-suite.yaml.
// Override with the +SUITE_YAML plusarg:
//   +SUITE_YAML=RISC_V/tests/specs/baseline-suite.yaml

`timescale 1ns/1ps

import cpu_test_pkg::*;

// ============================================================
// yaml_loader
// Reads the YAML suite file and fills test_descriptors[].
// Exposed as a module so it can be instantiated and its outputs
// read back as ordinary signals/variables after it completes.
// ============================================================
module yaml_loader #(
    parameter string YAML_FILE = "RISC_V/tests/specs/baseline-suite.yaml"
)(
    output int               num_tests,
    output test_descriptor_t test_descriptors [cpu_test_pkg::MAX_TESTS]
);
    // ---- parser state ----
    typedef enum logic [2:0] {
        S_IDLE,
        S_IN_TEST,
        S_IN_EXPECTED,
        S_IN_REGISTERS,
        S_IN_MEMORY
    } parse_state_t;

    initial begin : load_yaml
        int          fd;
        string       line;
        string       yaml_path;
        parse_state_t state;
        int          cur;           // index into test_descriptors
        string       val;
        int          indent;

        // allow plusarg override
        if (!$value$plusargs("SUITE_YAML=%s", yaml_path))
            yaml_path = YAML_FILE;

        fd = $fopen(yaml_path, "r");
        if (fd == 0) begin
            $fatal(1, "[yaml_loader] Cannot open YAML file: %s", yaml_path);
        end

        num_tests = 0;
        cur       = -1;
        state     = S_IDLE;

        while (!$feof(fd)) begin
            void'($fgets(line, fd));

            // --------------------------------------------------------
            // A new test entry begins with "  - test_name:"
            // We detect this by looking for "- test_name:" anywhere
            // in the line (after leading whitespace).
            // --------------------------------------------------------
            if (str_contains(line, "- test_name:")) begin
                if (num_tests < MAX_TESTS) begin
                    cur = num_tests;
                    num_tests++;
                    // initialise the descriptor
                    test_descriptors[cur].enabled        = 0;
                    test_descriptors[cur].max_cycles     = DEFAULT_MAX_CYCLES;
                    test_descriptors[cur].num_reg_checks = 0;
                    test_descriptors[cur].num_mem_checks = 0;
                    test_descriptors[cur].test_name      = strtrim(after_colon(line));
                    test_descriptors[cur].program_image  = "";
                    state = S_IN_TEST;
                end
                continue;
            end

            if (cur < 0) continue;  // haven't hit a test entry yet

            // --------------------------------------------------------
            // Fields inside a test entry
            // --------------------------------------------------------
            case (state)

                S_IN_TEST: begin
                    if (str_contains(line, "enabled:")) begin
                        val = strtrim(after_colon(line));
                        test_descriptors[cur].enabled = (val == "true") ? 1 : 0;
                    end
                    else if (str_contains(line, "program_image:")) begin
                        val = strtrim(after_colon(line));
                        if (val != "null")
                            test_descriptors[cur].program_image = val;
                    end
                    else if (str_contains(line, "max_cycles:")) begin
                        val = strtrim(after_colon(line));
                        test_descriptors[cur].max_cycles = parse_int(val);
                    end
                    else if (str_contains(line, "expected_final_state:")) begin
                        state = S_IN_EXPECTED;
                    end
                    // Any new list entry at the test level means we're back at top
                    else if (str_contains(line, "- test_name:")) begin
                        // handled above — won't reach here but be safe
                    end
                end

                S_IN_EXPECTED: begin
                    if (str_contains(line, "registers:")) begin
                        state = S_IN_REGISTERS;
                    end
                    else if (str_contains(line, "memory_words:")) begin
                        state = S_IN_MEMORY;
                    end
                    // falling out of expected_final_state back to test level
                    else if (str_contains(line, "pass_rule:") ||
                             str_contains(line, "notes:")) begin
                        state = S_IN_TEST;
                    end
                end

                S_IN_REGISTERS: begin
                    // Lines look like:  "        x3: \"0x0000000D\""
                    // Detect a register key by looking for x<digits>:
                    // We look for "x" followed by a digit followed by ":"
                    begin
                        automatic int found = 0;
                        for (int i = 0; i < line.len() - 2 && !found; i++) begin
                            if (line[i] == "x" &&
                                line[i+1] >= "0" && line[i+1] <= "9") begin
                                // extract register number
                                automatic string rnum = "";
                                automatic int j = i + 1;
                                while (j < line.len() &&
                                       line[j] >= "0" && line[j] <= "9") begin
                                    rnum = {rnum, line[j]};
                                    j++;
                                end
                                if (j < line.len() && line[j] == ":") begin
                                    automatic int ridx;
                                    automatic int nrc;
                                    ridx = parse_int(rnum);
                                    nrc  = test_descriptors[cur].num_reg_checks;
                                    if (ridx < 32 && nrc < MAX_REG_CHECKS) begin
                                        test_descriptors[cur].reg_checks[nrc].addr  = ridx[4:0];
                                        test_descriptors[cur].reg_checks[nrc].value =
                                            parse_hex32(after_colon(line));
                                        test_descriptors[cur].num_reg_checks = nrc + 1;
                                    end
                                    found = 1;
                                end
                            end
                        end
                        // leaving registers block
                        if (!found) begin
                            if (str_contains(line, "memory_words:"))
                                state = S_IN_MEMORY;
                            else if (str_contains(line, "pass_rule:") ||
                                     str_contains(line, "notes:")     ||
                                     str_contains(line, "- test_name:"))
                                state = S_IN_TEST;
                        end
                    end
                end

                S_IN_MEMORY: begin
                    // Lines look like:  "        \"0x00000100\": \"0x0000002A\""
                    // Check for a 0x address key
                    if (str_contains(line, "0x") || str_contains(line, "0X")) begin
                        automatic int nmc;
                        automatic string colon_val;
                        automatic string key_part;
                        nmc = test_descriptors[cur].num_mem_checks;
                        if (nmc < MAX_MEM_CHECKS) begin
                            // find first 0x to extract address
                            for (int i = 0; i < line.len() - 1; i++) begin
                                if (line[i] == "0" &&
                                    (line[i+1] == "x" || line[i+1] == "X")) begin
                                    key_part = line.substr(i, line.len()-1);
                                    test_descriptors[cur].mem_checks[nmc].addr =
                                        parse_hex32(key_part);
                                    break;
                                end
                            end
                            // value is after the ":"
                            colon_val = after_colon(line);
                            test_descriptors[cur].mem_checks[nmc].value =
                                parse_hex32(colon_val);
                            test_descriptors[cur].num_mem_checks = nmc + 1;
                        end
                    end
                    else if (str_contains(line, "pass_rule:") ||
                             str_contains(line, "notes:")     ||
                             str_contains(line, "- test_name:")) begin
                        state = S_IN_TEST;
                    end
                end

            endcase
        end

        $fclose(fd);
        $display("[yaml_loader] Loaded %0d test(s) from %s", num_tests, yaml_path);
    end

endmodule


// ============================================================
// cpu_suite_runner  (program block)
// Drives the DUT through cpu_if, runs each enabled test, checks results.
// ============================================================
program cpu_suite_runner (
    cpu_if.tb          iface,
    input int          num_tests,
    input test_descriptor_t test_descriptors [cpu_test_pkg::MAX_TESTS]
);
    import cpu_test_pkg::*;

    // Shadow register file — mirrors every WB-bus write
    logic [31:0] shadow_regs [32];

    // Per-suite counters
    int tests_run;
    int tests_passed;
    int tests_failed;

    // ----------------------------------------------------------------
    // task: reset_dut
    // ----------------------------------------------------------------
    task reset_dut();
        iface.tb_cb.reset        <= 1;
        iface.tb_cb.imem_read_en <= 0;
        @(iface.tb_cb);          // hold reset for 2 rising edges
        @(iface.tb_cb);
        iface.tb_cb.reset        <= 0;
        iface.tb_cb.imem_read_en <= 1;
        @(iface.tb_cb);          // one more cycle before we start watching
    endtask

    // ----------------------------------------------------------------
    // task: clear_shadow
    // ----------------------------------------------------------------
    task clear_shadow();
        for (int i = 0; i < 32; i++) shadow_regs[i] = 32'h0;
    endtask

    // ----------------------------------------------------------------
    // task: run_one_test
    //   Runs a single test to completion or timeout.
    //   Returns 1 if the CPU reached the stop condition within budget,
    //   0 if it timed out.
    // ----------------------------------------------------------------
    task run_one_test(
        input  test_descriptor_t td,
        output bit               reached_stop,
        output int               cycles_taken
    );
        reached_stop = 0;
        cycles_taken = 0;

        for (int cyc = 0; cyc < td.max_cycles; cyc++) begin
            @(iface.tb_cb);
            cycles_taken = cyc + 1;

            // capture WB bus into shadow
            begin
                automatic logic [4:0]  wa = iface.tb_cb.reg_writeaddr;
                automatic logic [31:0] wd = iface.tb_cb.reg_writedata;
                if (wa != 5'h0)             // x0 is hardwired zero, never update
                    shadow_regs[wa] = wd;
            end

            // stop condition: x12 written with 1
            if (iface.tb_cb.reg_writeaddr == STOP_REG[4:0] &&
                iface.tb_cb.reg_writedata  == STOP_VAL) begin
                reached_stop = 1;
                break;
            end
        end
    endtask

    // ----------------------------------------------------------------
    // task: check_results
    //   Compares shadow_regs and DUT memory against expected values.
    //   Prints a pass/fail line for each check.
    //   Returns 1 only if all checks pass.
    // ----------------------------------------------------------------
    task check_results(
        input  test_descriptor_t td,
        output bit               all_pass
    );
        all_pass = 1;

        // --- register checks ---
        for (int i = 0; i < td.num_reg_checks; i++) begin
            automatic logic [4:0]  ra  = td.reg_checks[i].addr;
            automatic logic [31:0] exp = td.reg_checks[i].value;
            automatic logic [31:0] got = shadow_regs[ra];
            if (got !== exp) begin
                $display("    [FAIL] x%0d: expected 0x%08X, got 0x%08X", ra, exp, got);
                all_pass = 0;
            end else begin
                $display("    [PASS] x%0d: 0x%08X", ra, got);
            end
        end

        // --- memory checks ---
        for (int i = 0; i < td.num_mem_checks; i++) begin
            automatic logic [31:0] maddr = td.mem_checks[i].addr;
            automatic logic [31:0] exp   = td.mem_checks[i].value;
            // Hierarchical reference into the DUT's byte-array data memory.
            // Path: tb_cpu_suite.dut_inst -> int_Memory -> dmem -> data_memory
            // Memory is big-endian: byte[addr+0] is the most-significant byte.
            automatic logic [31:0] widx = maddr & 32'hFFFF_FFFC;
            automatic logic [31:0] got;
            got = { $root.tb_cpu_suite.dut_inst.int_Memory.dmem.data_memory[widx],
                    $root.tb_cpu_suite.dut_inst.int_Memory.dmem.data_memory[widx+1],
                    $root.tb_cpu_suite.dut_inst.int_Memory.dmem.data_memory[widx+2],
                    $root.tb_cpu_suite.dut_inst.int_Memory.dmem.data_memory[widx+3] };
            if (got !== exp) begin
                $display("    [FAIL] mem[0x%08X]: expected 0x%08X, got 0x%08X",
                         maddr, exp, got);
                all_pass = 0;
            end else begin
                $display("    [PASS] mem[0x%08X]: 0x%08X", maddr, got);
            end
        end
    endtask

    // ----------------------------------------------------------------
    // Main flow
    // ----------------------------------------------------------------
    initial begin
        tests_run    = 0;
        tests_passed = 0;
        tests_failed = 0;

        $display("========================================================");
        $display(" RISC-V Baseline Suite");
        $display("========================================================");

        for (int t = 0; t < num_tests; t++) begin
            automatic test_descriptor_t td = test_descriptors[t];

            if (!td.enabled) begin
                $display("[SKIP] %s", td.test_name);
                continue;
            end

            if (td.program_image == "") begin
                $display("[SKIP] %s  (no program_image)", td.test_name);
                continue;
            end

            $display("--------------------------------------------------------");
            $display("[RUN ] %s", td.test_name);
            $display("       image   : %s", td.program_image);
            $display("       budget  : %0d cycles", td.max_cycles);

            // Re-load instruction memory for this test.
            // $readmemh on the ROM inside the DUT via hierarchical path.
            $readmemh(td.program_image,
                $root.tb_cpu_suite.dut_inst.int_Fetch.int_imem.rom);

            clear_shadow();
            reset_dut();

            begin
                automatic bit reached_stop;
                automatic int cycles_taken;
                automatic bit all_pass;

                run_one_test(td, reached_stop, cycles_taken);

                if (!reached_stop) begin
                    $display("       [FAIL] Timed out after %0d cycles (stop condition not reached)",
                             cycles_taken);
                    tests_run++;
                    tests_failed++;
                    continue;
                end

                $display("       cycles  : %0d", cycles_taken);
                check_results(td, all_pass);

                tests_run++;
                if (all_pass) begin
                    tests_passed++;
                    $display("       RESULT  : PASS");
                end else begin
                    tests_failed++;
                    $display("       RESULT  : FAIL");
                end
            end
        end

        $display("========================================================");
        $display(" Suite complete: %0d run, %0d passed, %0d failed",
                 tests_run, tests_passed, tests_failed);
        $display("========================================================");
        $finish;
    end

endprogram


// ============================================================
// tb_cpu_suite  (top module)
// ============================================================
module tb_cpu_suite;
    import cpu_test_pkg::*;

    // ----------------------------------------------------------------
    // Clock generation
    // ----------------------------------------------------------------
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;   // 100 MHz — 10 ns period

    // ----------------------------------------------------------------
    // Interface instance
    // ----------------------------------------------------------------
    cpu_if the_if (.clk(clk));

    // ----------------------------------------------------------------
    // DUT instance — wired through the .dut modport
    // INIT_FILE is irrelevant here because the runner overwrites the ROM
    // via $readmemh before each test; any valid file (or empty) is fine.
    // ----------------------------------------------------------------
    RISC_V_02 #(
        .INIT_FILE("")
    ) dut_inst (
        .clk            (the_if.clk),
        .reset          (the_if.reset),
        .imem_read_en   (the_if.imem_read_en),
        .reg_writedata  (the_if.reg_writedata),
        .reg_writeaddr  (the_if.reg_writeaddr)
    );

    // ----------------------------------------------------------------
    // YAML loader instance
    // ----------------------------------------------------------------
    int              num_tests;
    test_descriptor_t test_descriptors [MAX_TESTS];

    yaml_loader #(
        .YAML_FILE("RISC_V/tests/specs/baseline-suite.yaml")
    ) loader (
        .num_tests       (num_tests),
        .test_descriptors(test_descriptors)
    );

    // ----------------------------------------------------------------
    // Test runner instance
    // ----------------------------------------------------------------
    cpu_suite_runner runner (
        .iface           (the_if),
        .num_tests       (num_tests),
        .test_descriptors(test_descriptors)
    );

endmodule
