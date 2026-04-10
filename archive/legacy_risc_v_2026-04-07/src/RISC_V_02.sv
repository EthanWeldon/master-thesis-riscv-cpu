module RISC_V_02 (
    input logic clk,
    input logic reset,
    input logic imem_read_en,

    output [31:0] reg_writedata,
    output logic [4:0] reg_writeaddr
);
    
// Instruction Memory Wires
logic [31:0] instr_f;
logic [31:0] pc_f;
logic [31:0] pc_branch;
logic [1:0] pc_branch_en_sel;
logic flush_fd;
logic flush_de;
logic [31:0] pc_d_1;

// Fetch Stage
Fetch_Stage_bp int_Fetch (
    // Inputs
    .clk(clk),
    .rst(reset),
    // Bracnh predictor
    .pc_branch(pc_branch),
    .pc_branch_en_sel(pc_branch_en_sel),
    .pc_d(pc_d_1),
    .imem_read_en(imem_read_en),
    // Outputs
    .flush_fd(flush_fd),
    .flush_de(flush_de),
    .pc_f(pc_f),
    .instr_f(instr_f)
);

logic [31:0] instr_d;
// FE_DE Pipeline
FE_DE int_Fe_DE (
    // Inputs
    .clk(clk),
    .reset(reset),
    .pipe_flush(flush_fd),
    // Fetch IN
    .instr_f(instr_f),
    .pc_f(pc_f),
    // Decode OUT
    .instr_d(instr_d),
    .pc_d(pc_d_1)
);

// Decode Stage Wires
logic [4:0] reg_write_addr_w;
logic reg_write_en_w;
logic [31:0] reg_writedata_w;

logic reg_write_en_d;
logic [4:0] reg_write_addr_d;
logic pcadder_in1_sel_d;
logic pcadder_in2_sel_d;
logic pcadder_out_sel_d;
logic pcadder_out_merge_sel_d;
logic alu_en_d;
logic [4:0] alu_op_d;
logic alu_mul_data2_sel_d;
logic mul_en_d;
logic [1:0] execute_out_sel_d;
logic dmem_read_en_d;
logic dmem_write_en_d;
logic reg_writedata_sel_dl;
logic [4:0] reg_read_addr1_d;
logic [4:0] reg_read_addr2_d;
logic [31:0] reg_readdata1_d;
logic [31:0] reg_readdata2_d;
logic [31:0] imm_data_d;
logic [31:0] pc_d_2;


// Decode Stage
Decode_Stage int_Decode (
    // Input
    .clk(clk),
    .instr_d(instr_d),
    .pc_d_in(pc_d_1),

    // WriteBack signals
    .reg_write_addr_w(reg_write_addr_w),
    .reg_write_en_w(reg_write_en_w),
    .reg_writedata_w(reg_writedata_w),

    // Output
    .reg_write_en_d(reg_write_en_d),
    .reg_write_addr_d(reg_write_addr_d),
    .pcadder_in1_sel_d(pcadder_in1_sel_d),
    .pcadder_in2_sel_d(pcadder_in2_sel_d),
    .pcadder_out_sel_d(pcadder_out_sel_d),
    .pcadder_out_merge_sel_d(pcadder_out_merge_sel_d),
    .alu_en_d(alu_en_d),
    .alu_op_d(alu_op_d),
    .alu_mul_data2_sel_d(alu_mul_data2_sel_d),
    .mul_en_d(mul_en_d),
    .execute_out_sel_d(execute_out_sel_d),
    .dmem_read_en_d(dmem_read_en_d),
    .dmem_write_en_d(dmem_write_en_d),
    .reg_writedata_sel_d(reg_writedata_sel_d),
    .reg_read_addr1_d(reg_read_addr1_d),
    .reg_read_addr2_d(reg_read_addr2_d),
    .reg_readdata1_d(reg_readdata1_d),
    .reg_readdata2_d(reg_readdata2_d),
    .imm_data_d(imm_data_d),
    .pc_d_out(pc_d_2)
);

// Execute Stage Wires
logic [31:0] pc_e;
logic reg_write_en_e_1;
logic [4:0] reg_write_addr_e_1;
logic pcadder_in1_sel_e;
logic pcadder_in2_sel_e;
logic pcadder_out_sel_e;
logic pcadder_out_merge_sel_e;
logic alu_en_e;
logic [4:0] alu_op_e;
logic alu_mul_data2_sel_e;
logic mul_en_e;
logic [1:0] execute_out_sel_e;
logic dmem_read_en_e_1;
logic dmem_write_en_e_1;
logic reg_writedata_sel_e_1;
logic [4:0] reg_read_addr1_e;
logic [4:0] reg_read_addr2_e;
logic [31:0] reg_readdata1_e;
logic [31:0] reg_readdata2_e_1;
logic [31:0] imm_data_e;

// DE_EX Pipeline
DE_EX int_De_Ex (
    // Inputs
    .clk(clk),
    .reset(reset),
    .pipe_flush(flush_de),
    
    // Decode IN
    .reg_write_en_d(reg_write_en_d),
    .reg_write_addr_d(reg_write_addr_d),
    .pcadder_in1_sel_d(pcadder_in1_sel_d),
    .pcadder_in2_sel_d(pcadder_in2_sel_d),
    .pcadder_out_sel_d(pcadder_out_sel_d),
    .pcadder_out_merge_sel_d(pcadder_out_merge_sel_d),
    .alu_en_d(alu_en_d),
    .alu_op_d(alu_op_d),
    .alu_mul_data2_sel_d(alu_mul_data2_sel_d),
    .mul_en_d(mul_en_d),
    .execute_out_sel_d(execute_out_sel_d),
    .dmem_read_en_d(dmem_read_en_d),
    .dmem_write_en_d(dmem_write_en_d),
    .reg_writedata_sel_d(reg_writedata_sel_d),
    .reg_read_addr1_d(reg_read_addr1_d),
    .reg_read_addr2_d(reg_read_addr2_d),
    .reg_readdata1_d(reg_readdata1_d),
    .reg_readdata2_d(reg_readdata2_d),
    .imm_data_d(imm_data_d),
    .pc_d(pc_d_2),

    // Execute OUT
    .pc_e(pc_e),
    .reg_write_en_e(reg_write_en_e_1),
    .reg_write_addr_e(reg_write_addr_e_1),
    .pcadder_in1_sel_e(pcadder_in1_sel_e),
    .pcadder_in2_sel_e(pcadder_in2_sel_e),
    .pcadder_out_sel_e(pcadder_out_sel_e),
    .pcadder_out_merge_sel_e(pcadder_out_merge_sel_e),
    .alu_en_e(alu_en_e),
    .alu_op_e(alu_op_e),
    .alu_mul_data2_sel_e(alu_mul_data2_sel_e),
    .mul_en_e(mul_en_e),
    .execute_out_sel_e(execute_out_sel_e),
    .dmem_read_en_e(dmem_read_en_e_1),
    .dmem_write_en_e(dmem_write_en_e_1),
    .reg_writedata_sel_e(reg_writedata_sel_e_1),
    .reg_read_addr1_e(reg_read_addr1_e),
    .reg_read_addr2_e(reg_read_addr2_e),
    .reg_readdata1_e(reg_readdata1_e),
    .reg_readdata2_e(reg_readdata2_e_1),
    .imm_data_e(imm_data_e)
);

// More wires for Execute Stage
logic [1:0] alumul_data1_sel_e;
logic [1:0] alumul_forward_sel_e;
logic [31:0] execute_out_e;
logic [4:0] reg_write_addr_e_2;
logic reg_write_en_e_2;
logic dmem_read_en_e_2;
logic dmem_write_en_e_2;
logic reg_writedata_sel_e_2;
logic [31:0] reg_readdata2_e_2;
logic [31:0] execute_out_m_1;
logic [31:0] execute_out_w;

// Execute Stage
Execute_Stage int_Execute (
    // Inputs
    .pc_e(pc_e),
    .immediate_e(imm_data_e),
    .reg_readdata1_e(reg_readdata1_e),
    .reg_readdata2_e(reg_readdata2_e_1),
    .pcadder_out_sel_e(pcadder_out_sel_e),
    .alu_op_e(alu_op_e),
    .alu_en_e(alu_en_e),
    .mul_en_e(mul_en_e),
    .pcadder_in1_sel_e(pcadder_in1_sel_e),
    .pcadder_in2_sel_e(pcadder_in2_sel_e),
    .alumul_data1_sel_e(alumul_data1_sel_e),
    .alumul_data2_sel_e(alu_mul_data2_sel_e),
    .alumul_forward_sel_e(alumul_forward_sel_e),
    .execute_out_sel_e(execute_out_sel_e),
    .pcadder_out_merge_sel_e(pcadder_out_merge_sel_e),
    .execute_out_m(execute_out_m_1),
    .execute_out_w(execute_out_w),
    
    // Input External signals
    .reg_write_addr_e(reg_write_addr_e_1),
    .reg_write_en_e(reg_write_en_e_1),
    .dmem_read_en_e(dmem_read_en_e_1),
    .dmem_write_en_e(dmem_write_en_e_1),
    .reg_writedata_sel_e(reg_writedata_sel_e_1),

    // Outputs
    .execute_out_e(execute_out_e),
    .pc_branch(pc_branch),
    .pc_branch_en_sel(pc_branch_en_sel),

    // Output External signals
    .reg_write_addr_m(reg_write_addr_e_2),
    .reg_write_en_m(reg_write_en_e_2),
    .dmem_read_en_m(dmem_read_en_e_2),
    .dmem_write_en_m(dmem_write_en_e_2),
    .reg_writedata_sel_m(reg_writedata_sel_e_2),
    .reg_readdata2_m(reg_readdata2_e_2)
);

// Memory Stage Wires
logic [4:0] reg_write_addr_m_1;
logic reg_write_en_m_1;
logic dmem_read_en_m;
logic dmem_write_en_m;
logic reg_writedata_sel_m_1;
logic [31:0] reg_readdata2_m;

// EX_MEM Pipeline
EX_MEM int_Ex_Mem (
    // Inputs
    .clk(clk),
    .reset(reset),
    
    // Execute IN
    .execute_out_e(execute_out_e),
    .reg_write_addr_e(reg_write_addr_e_2),
    .reg_write_en_e(reg_write_en_e_2),
    .dmem_read_en_e(dmem_read_en_e_2),
    .dmem_write_en_e(dmem_write_en_e_2),
    .reg_writedata_sel_e(reg_writedata_sel_e_2),
    .reg_readdata2_e(reg_readdata2_e_2),

    // Memory OUT
    .execute_out_m(execute_out_m_1),
    .reg_write_addr_m(reg_write_addr_m_1),
    .reg_write_en_m(reg_write_en_m_1),
    .dmem_read_en_m(dmem_read_en_m),
    .dmem_write_en_m(dmem_write_en_m),
    .reg_writedata_sel_m(reg_writedata_sel_m_1),
    .reg_readdata2_m(reg_readdata2_m)
);

// Forwarding Unit
Forwarding_Unit_Block int_Forward(
    // Inputs
    .reg_writeaddress_m(reg_write_addr_m_1),
    .reg_readaddress1_e(reg_read_addr1_e),
    .reg_readaddress2_e(reg_read_addr2_e),
    .reg_writeaddress(reg_write_addr_w),

    // Outputs
    .alumul_data1_sel_e(alumul_data1_sel_e),
    .alumul_forward_sel_e(alumul_forward_sel_e)
);

logic [31:0] dmem_readdata_m;
logic [31:0] execute_out_m_2;
logic [4:0] reg_write_addr_m_2;
logic reg_write_en_m_2;
logic reg_writedata_sel_m_2;

// Memory Stage
Memory_Stage int_Memory(
    // Input
    .reg_readdata2_m(reg_readdata2_m),
    .execute_out_m_in(execute_out_m_1),
    .reg_write_addr_m_in(reg_write_addr_m_1),
    .reg_write_en_m_in(reg_write_en_m_1),
    .reg_writedata_sel_m_in(reg_writedata_sel_m_1),
    .dmem_read_en_m(dmem_read_en_m),
    .dmem_write_en_m(dmem_write_en_m),
    // Output
    .dmem_readdata_m(dmem_readdata_m),
    .execute_out_m_out(execute_out_m_2),
    .reg_write_addr_m_out(reg_write_addr_m_2),
    .reg_write_en_m_out(reg_write_en_m_2),
    .reg_writedata_sel_m_out(reg_writedata_sel_m_2)
);

// Writeback Stage Wires
logic [31:0] dmem_readdata_w;
logic [4:0] reg_write_addr_w_2;
logic reg_write_en_w_2;
logic reg_writedata_sel_w;

// MEM_WB Pipeline
MEM_WB int_Mem_Wb (
    // Inputs
    .clk(clk),
    .reset(reset),
    
    // MEM IN
    .dmem_readdata_m(dmem_readdata_m),
    .execute_out_m(execute_out_m_2),
    .reg_write_addr_m(reg_write_addr_m_2),
    .reg_write_en_m(reg_write_en_m_2),
    .reg_writedata_sel_m(reg_writedata_sel_m_2),

    // WB OUT
    .dmem_readdata_w(dmem_readdata_w),
    .execute_out_w(execute_out_w),
    .reg_write_addr_w(reg_write_addr_w_2),
    .reg_write_en_w(reg_write_en_w_2),
    .reg_writedata_sel_w(reg_writedata_sel_w)
);

// Writeback Stage
Writeback_Stage int_Writeback (
    // Inputs
    .dmem_readdata_w_in(dmem_readdata_w),
    .execute_out_w_in(execute_out_w),
    .reg_write_addr_w_in(reg_write_addr_w_2),
    .reg_write_en_w_in(reg_write_en_w_2),
    .reg_writedata_sel_w(reg_writedata_sel_w),

    // Outputs
    .reg_writedata_w(reg_writedata_w),
    .reg_write_addr_w_out(reg_write_addr_w),
    .reg_write_en_w_out(reg_write_en_w)
);

assign reg_writeaddr = reg_write_addr_w;
assign reg_writedata = reg_writedata_w;

endmodule