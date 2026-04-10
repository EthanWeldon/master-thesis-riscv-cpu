module DE_EX (
    input logic clk,
    input logic reset,
    input logic pipe_flush,

    // Signals from Decode Stage
    input logic [31:0] pc_d,
    input logic reg_write_en_d,
    input logic [4:0] reg_write_addr_d,
    input logic pcadder_in1_sel_d,
    input logic pcadder_in2_sel_d,
    input logic pcadder_out_sel_d,
    input logic pcadder_out_merge_sel_d,
    input logic alu_en_d,
    input logic [4:0] alu_op_d,
    input logic alu_mul_data2_sel_d,
    input logic mul_en_d,
    input logic [1:0] execute_out_sel_d,
    input logic dmem_read_en_d,
    input logic dmem_write_en_d,
    input logic reg_writedata_sel_d,
    input logic [4:0] reg_read_addr1_d,
    input logic [4:0] reg_read_addr2_d,
    input logic [31:0] reg_readdata1_d,
    input logic [31:0] reg_readdata2_d,
    input logic [31:0] imm_data_d,

    // Signals to Execute Stage
    output logic [31:0] pc_e,
    output logic reg_write_en_e,
    output logic [4:0] reg_write_addr_e,
    output logic pcadder_in1_sel_e,
    output logic pcadder_in2_sel_e,
    output logic pcadder_out_sel_e,
    output logic pcadder_out_merge_sel_e,
    output logic alu_en_e,
    output logic [4:0] alu_op_e,
    output logic alu_mul_data2_sel_e,
    output logic mul_en_e,
    output logic [1:0] execute_out_sel_e,
    output logic dmem_read_en_e,
    output logic dmem_write_en_e,
    output logic reg_writedata_sel_e,
    output logic [4:0] reg_read_addr1_e,
    output logic [4:0] reg_read_addr2_e,
    output logic [31:0] reg_readdata1_e, 
    output logic [31:0] reg_readdata2_e,
    output logic [31:0] imm_data_e
);

    always_ff @(posedge clk) begin
        if (reset || pipe_flush) begin
            pc_e <= 32'b0;
            reg_write_en_e <= 1'b0;
            reg_write_addr_e <= 5'b0;
            pcadder_in1_sel_e <= 1'b0;
            pcadder_in2_sel_e <= 1'b0;
            pcadder_out_sel_e <= 1'b0;
            pcadder_out_merge_sel_e <= 1'b0;
            alu_en_e <= 1'b0;
            alu_op_e <= 5'b0;
            alu_mul_data2_sel_e <= 1'b0;
            mul_en_e <= 1'b0;
            execute_out_sel_e <= 2'b0;
            dmem_read_en_e <= 1'b0;
            dmem_write_en_e <= 1'b0;
            reg_writedata_sel_e <= 1'b0;
            reg_read_addr1_e <= 5'b0;
            reg_read_addr2_e <= 5'b0;
            reg_readdata1_e <= 32'b0;
            reg_readdata2_e <= 32'b0;
            imm_data_e <= 32'b0;
        end else begin
            pc_e <= pc_d;
            reg_write_en_e <= reg_write_en_d;
            reg_write_addr_e <= reg_write_addr_d;
            pcadder_in1_sel_e <= pcadder_in1_sel_d;
            pcadder_in2_sel_e <= pcadder_in2_sel_d;
            pcadder_out_sel_e <= pcadder_out_sel_d;
            pcadder_out_merge_sel_e <= pcadder_out_merge_sel_d;
            alu_en_e <= alu_en_d;
            alu_op_e <= alu_op_d;
            alu_mul_data2_sel_e <= alu_mul_data2_sel_d;
            mul_en_e <= mul_en_d;
            execute_out_sel_e <= execute_out_sel_d;
            dmem_read_en_e <= dmem_read_en_d;
            dmem_write_en_e <= dmem_write_en_d;
            reg_writedata_sel_e <= reg_writedata_sel_d;
            reg_read_addr1_e <= reg_read_addr1_d;
            reg_read_addr2_e <= reg_read_addr2_d;
            reg_readdata1_e <= reg_readdata1_d;
            reg_readdata2_e <= reg_readdata2_d;
            imm_data_e <= imm_data_d;
        end
    end

endmodule