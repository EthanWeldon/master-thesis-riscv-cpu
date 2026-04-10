module Execute_Stage(
    // Inputs
    input [31:0] pc_e, 
    input [31:0] immediate_e, 
    input [31:0] reg_readdata1_e, 
    input [31:0] reg_readdata2_e, 
    input pcadder_out_sel_e, 
    input [4:0] alu_op_e,
    input alu_en_e,
    input mul_en_e, 
    input pcadder_in1_sel_e,
    input pcadder_in2_sel_e,
    input [1:0] alumul_data1_sel_e,
    input alumul_data2_sel_e,
    input [1:0] alumul_forward_sel_e,
    input [1:0] execute_out_sel_e,
    input pcadder_out_merge_sel_e,
    input [31:0] execute_out_m,
    input [31:0] execute_out_w,

    // Input External signals
    input [4:0] reg_write_addr_e,
    input reg_write_en_e,
    input dmem_read_en_e,
    input dmem_write_en_e,
    input reg_writedata_sel_e,
    
    // Outputs
    output logic [31:0] execute_out_e,
    output logic [31:0] pc_branch,
    output logic [1:0] pc_branch_en_sel,

    // Output External signals
    output logic [4:0] reg_write_addr_m,
    output logic reg_write_en_m,
    output logic dmem_read_en_m,
    output logic dmem_write_en_m,
    output logic reg_writedata_sel_m,
    output logic [31:0] reg_readdata2_m
);

// Internal wires
logic [31:0] immediate_e_shifted;
logic [31:0] pcadder_in1;
logic [31:0] pcadder_in2;
logic [31:0] pcadder_out;
logic [31:0] pc_plusimm;
logic [31:0] pc_e_plus4;
logic [31:0] pcadder_out_merge;
logic [31:0] pcadder_out_rounded;
logic [31:0] alumul_data1;
logic [31:0] alumul_data2;
logic [31:0] alumul_forward;
logic [31:0] alu_out;
logic [31:0] mul_out;

// Instantiate ALU
ALU_Block int_alu(
    .reg_readdata1_e(alumul_data1),
    .alumul_data2(alumul_data2),
    .alu_op_e(alu_op_e),
    .alu_en_e(alu_en_e),
    .alu_out(alu_out),
    .pc_branch_en_sel(pc_branch_en_sel)
);

always_comb begin
    // Passing signals
    reg_write_addr_m = reg_write_addr_e; 
    reg_write_en_m = reg_write_en_e; 
    dmem_read_en_m = dmem_read_en_e; 
    dmem_write_en_m = dmem_write_en_e; 
    reg_writedata_sel_m = reg_writedata_sel_e;

    // ALU/MUL
    alumul_data1 = (alumul_data1_sel_e[1]) ? (alumul_data1_sel_e[0] ? 32'b0 : execute_out_w) : (alumul_data1_sel_e[0] ? execute_out_m : reg_readdata1_e);
    alumul_forward = (alumul_forward_sel_e[1]) ?  (alumul_forward_sel_e[0] ? 32'b0 : execute_out_w) : (alumul_forward_sel_e[0] ? execute_out_m : reg_readdata2_e);
    alumul_data2 = (alumul_data2_sel_e) ? immediate_e : alumul_forward;
    mul_out = (mul_en_e) ? $signed(alumul_data1) * $signed(alumul_data2) : 32'h0000_0000;

    reg_readdata2_m = alumul_forward; // Pass through reg_readdata2 for memory stage

    // PC Adder
    immediate_e_shifted = immediate_e << 12;
    pcadder_in1 = (pcadder_in1_sel_e) ? reg_readdata1_e : pc_e;
    pcadder_in2 = (pcadder_in2_sel_e) ? immediate_e_shifted : immediate_e;
    pcadder_out = $signed(pcadder_in1) + $signed(pcadder_in2);
    pcadder_out_rounded = pcadder_out;
    pcadder_out_rounded[1:0] = 2'b00;
    pcadder_out_merge = (pcadder_out_sel_e) ? pcadder_out_rounded : pcadder_out;
    pc_branch = (pcadder_out_merge_sel_e) ? 32'h0000_0000 : pcadder_out_merge;
    pc_plusimm = (pcadder_out_merge_sel_e) ? pcadder_out : 32'h0000_0000;
    pc_e_plus4 = pc_e + 4;

    // Execute Out MUX
    case (execute_out_sel_e)
        2'b00: execute_out_e = pc_plusimm;
        2'b01: execute_out_e = alu_out;
        2'b10: execute_out_e = mul_out;
        2'b11: execute_out_e = pc_e_plus4;
        default: execute_out_e = 32'h0000_0000;
    endcase
end
endmodule