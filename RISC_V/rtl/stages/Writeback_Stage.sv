module Writeback_Stage(
    // Inputs
    input logic [31:0] dmem_readdata_w_in,
    input logic [31:0] execute_out_w_in, 
    input logic [4:0] reg_write_addr_w_in,
    input logic reg_write_en_w_in,
    input logic reg_writedata_sel_w,

    // Outputs
    output logic [31:0] reg_writedata_w,
    output logic [4:0] reg_write_addr_w_out,
    output logic reg_write_en_w_out
);

always_comb begin
    reg_writedata_w = (reg_writedata_sel_w) ? execute_out_w_in : dmem_readdata_w_in;
    reg_write_addr_w_out = reg_write_addr_w_in;
    reg_write_en_w_out = reg_write_en_w_in;
end

endmodule