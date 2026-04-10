module Decode_Stage(
    input logic clk,
    input logic [31:0] instr_d,             // Instruction from the fetch stage
    input logic [31:0] pc_d_in,               // Program Counter from the fetch stage

    // Signals from Write Back Stage
    input logic [4:0]  reg_write_addr_w,
    input logic        reg_write_en_w,
    input logic [31:0] reg_writedata_w,


    // Outputs to the next stage
    // Fowared signals to the next stage
    output logic reg_write_en_d,
    output logic [4:0] reg_write_addr_d,
    output logic pcadder_in1_sel_d,
    output logic pcadder_in2_sel_d,
    output logic pcadder_out_sel_d,
    output logic pcadder_out_merge_sel_d,
    output logic alu_en_d,
    output logic [4:0] alu_op_d,
    output logic alu_mul_data2_sel_d,
    output logic mul_en_d,
    output logic [1:0] execute_out_sel_d,
    output logic dmem_read_en_d,
    output logic dmem_write_en_d,
    output logic reg_writedata_sel_d,
    output logic [4:0] reg_read_addr1_d,
    output logic [4:0] reg_read_addr2_d,
    output logic [31:0] reg_readdata1_d,
    output logic [31:0] reg_readdata2_d,
    output logic [31:0] imm_data_d,
    output logic [31:0] pc_d_out
);

    // Internal wires from Control Unit
    logic immgen_en_d;
    logic [4:0] reg_read_addr1_d_wire;
    logic [4:0] reg_read_addr2_d_wire;
    logic [1:0] reg_read_en_d;
    logic reg_write_en_d_wire;
    logic [4:0] reg_write_addr_d_wire;
    logic pcadder_in1_sel_d_wire;
    logic pcadder_in2_sel_d_wire;
    logic pcadder_out_sel_d_wire;
    logic pcadder_out_merge_sel_d_wire;
    logic alu_en_d_wire;
    logic [4:0] alu_op_d_wire;
    logic alu_mul_data2_sel_d_wire;
    logic mul_en_d_wire;
    logic [1:0] execute_out_sel_d_wire;
    logic dmem_read_en_d_wire;
    logic dmem_write_en_d_wire;
    logic reg_writedata_sel_d_wire;

    // Instantiate Control Unit Block
    Control_Unit_Block control_unit_inst (
        .instr(instr_d),
        .immgen_en_d(immgen_en_d),
        .reg_read_addr1_d(reg_read_addr1_d_wire),
        .reg_read_addr2_d(reg_read_addr2_d_wire),
        .reg_read_en_d(reg_read_en_d),
        .reg_write_en_d(reg_write_en_d_wire),
        .reg_write_addr_d(reg_write_addr_d_wire),
        .pcadder_in1_sel_d(pcadder_in1_sel_d_wire),
        .pcadder_in2_sel_d(pcadder_in2_sel_d_wire),
        .pcadder_out_sel_d(pcadder_out_sel_d_wire),
        .pcadder_out_merge_sel_d(pcadder_out_merge_sel_d_wire),
        .alu_en_d(alu_en_d_wire),
        .alu_op_d(alu_op_d_wire),
        .alu_mul_data2_sel_d(alu_mul_data2_sel_d_wire),
        .mul_en_d(mul_en_d_wire),
        .execute_out_sel_d(execute_out_sel_d_wire),
        .dmem_read_en_d(dmem_read_en_d_wire),
        .dmem_write_en_d(dmem_write_en_d_wire),
        .reg_writedata_sel_d(reg_writedata_sel_d_wire)
    );

    // Register File Block — using testbench write inputs directly
    Register_File_Block register_file_inst (
        .clk(clk),
        .reg_read_addr1_d(reg_read_addr1_d_wire),
        .reg_read_addr2_d(reg_read_addr2_d_wire),
        .reg_read_en_d(reg_read_en_d),
        .reg_write_addr_d(reg_write_addr_w),
        .reg_write_en_d(reg_write_en_w),
        .writeData(reg_writedata_w),
        .reg_readdata1_d(reg_readdata1_d),
        .reg_readdata2_d(reg_readdata2_d)
    );

    // Immediate Generator Block
    Immediate_Generator_Block imm_gen_inst (
        .instruction(instr_d),
        .immgen_en_d(immgen_en_d),
        .imm_out(imm_data_d)
    );

    // Forward control unit signals to output ports
    always_comb begin
        reg_write_en_d          = reg_write_en_d_wire;
        reg_write_addr_d        = reg_write_addr_d_wire;
        pcadder_in1_sel_d       = pcadder_in1_sel_d_wire;
        pcadder_in2_sel_d       = pcadder_in2_sel_d_wire;
        pcadder_out_sel_d       = pcadder_out_sel_d_wire;
        pcadder_out_merge_sel_d = pcadder_out_merge_sel_d_wire;
        alu_en_d                = alu_en_d_wire;
        alu_op_d                = alu_op_d_wire;
        alu_mul_data2_sel_d     = alu_mul_data2_sel_d_wire;
        mul_en_d                = mul_en_d_wire;
        execute_out_sel_d       = execute_out_sel_d_wire;
        dmem_read_en_d          = dmem_read_en_d_wire;
        dmem_write_en_d         = dmem_write_en_d_wire;
        reg_writedata_sel_d     = reg_writedata_sel_d_wire;
        reg_read_addr1_d        = reg_read_addr1_d_wire;
        reg_read_addr2_d        = reg_read_addr2_d_wire;
        pc_d_out                = pc_d_in;
    end

endmodule
