// cpu_if.sv
// Interface between the testbench and RISC_V_02.
//
// Signals:
//   TB drives:  clk, reset, imem_read_en
//   DUT drives: reg_writedata, reg_writeaddr
//
// The clocking block synchronises TB sampling and driving to the clock edge.
//   - Inputs  (from DUT's perspective) are sampled 1ns before the rising edge.
//   - Outputs (driven by TB) are applied on the rising edge with 1ns skew.
//
// Modports:
//   cpu_if.dut  – used by RISC_V_02 (though the DUT is wired directly; provided
//                 for completeness and future wrapper use)
//   cpu_if.tb   – used by the testbench; drives through the clocking block

interface cpu_if (input logic clk);

    // ----------------------------------------------------------------
    // Signals
    // ----------------------------------------------------------------
    logic        reset;
    logic        imem_read_en;

    logic [31:0] reg_writedata;   // written by DUT
    logic [4:0]  reg_writeaddr;   // written by DUT

    // ----------------------------------------------------------------
    // Clocking block  (testbench view)
    // ----------------------------------------------------------------
    clocking tb_cb @(posedge clk);
        default input  #1 output #1;
        // TB drives these
        output reset;
        output imem_read_en;
        // TB samples these
        input  reg_writedata;
        input  reg_writeaddr;
    endclocking

    // ----------------------------------------------------------------
    // Modports
    // ----------------------------------------------------------------

    // Testbench drives / observes through the clocking block
    modport tb (
        clocking tb_cb,
        input    clk
    );

    // DUT connects to the raw signals directly
    modport dut (
        input  clk,
        input  reset,
        input  imem_read_en,
        output reg_writedata,
        output reg_writeaddr
    );

endinterface
