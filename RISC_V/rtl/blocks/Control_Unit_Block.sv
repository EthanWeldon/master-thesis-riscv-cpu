module Control_Unit_Block(

    input logic [31:0] instr,

    // Decode Stage Signals
    output logic immgen_en_d,
    output logic [4:0] reg_read_addr1_d,
    output logic [4:0] reg_read_addr2_d,
    output logic [1:0] reg_read_en_d,
    output logic reg_write_en_d,
    output logic [4:0] reg_write_addr_d,

    // Execute Stage Signals
    output logic pcadder_in1_sel_d,
    output logic pcadder_in2_sel_d,
    output logic pcadder_out_sel_d,
    output logic pcadder_out_merge_sel_d,
    output logic alu_en_d,
    output logic [4:0] alu_op_d,
    output logic alu_mul_data2_sel_d,
    output logic mul_en_d,
    output logic [1:0] execute_out_sel_d,

    // Memory Stage Signals
    output logic dmem_read_en_d,
    output logic dmem_write_en_d,

    // Write Back Stage Signals
    output logic reg_writedata_sel_d
);

logic [6:0]  opcode;
logic [4:0]  rd;
logic [2:0]  funct3;
logic [4:0]  rs1;
logic [4:0]  rs2;
logic [6:0]  funct7;

assign opcode  = instr[6:0];
assign rd      = instr[11:7];
assign funct3  = instr[14:12];
assign rs1     = instr[19:15];
assign rs2     = instr[24:20];
assign funct7  = instr[31:25];

always @(*) begin

    unique case (opcode)

        7'h33: begin // R-Type Instructions
            // Decode stage
            immgen_en_d = 0;
            reg_read_addr1_d = rs1;
            reg_read_addr2_d = rs2;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b11;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 1'b0;
            pcadder_in2_sel_d = 1'b0;
            pcadder_out_sel_d = 1'b0;
            pcadder_out_merge_sel_d = 1'b0;
            alu_en_d = 1;

            if (funct3 == 3'b000) begin
                if (funct7 == 7'b0000000) alu_op_d = 1; // ADD
                else if (funct7 == 7'b0100000) alu_op_d = 2; // SUB
                else if (funct7 == 7'b0000001) begin // MUL
                    alu_en_d = 0;
                    mul_en_d = 1;
                end 
            end
            else if (funct3 == 3'b111 && funct7 == 7'b0000000) alu_op_d = 3; // AND
            else if (funct3 == 3'b110 && funct7 == 7'b0000000) alu_op_d = 4; // OR
            else if (funct3 == 3'b100 && funct7 == 7'b0000000) alu_op_d = 5; // XOR
            else if (funct3 == 3'b010 && funct7 == 7'b0000000) alu_op_d = 6; // SLT
            else if (funct3 == 3'b011 && funct7 == 7'b0000000) alu_op_d = 7; // SLTU
            else if (funct3 == 3'b101) begin
                if (funct7 == 7'b0000000) alu_op_d = 9; // SRL (change to 8)
                else if (funct7 == 7'b0100000) alu_op_d = 8; // SRA
            end
            else if (funct3 == 3'b001 && funct7 == 7'b0000000) alu_op_d = 10; // SLL
            else alu_op_d = 0; // default NOP

            alu_mul_data2_sel_d = 0;
            execute_out_sel_d = 2'b01;
            // Memory stage
            dmem_read_en_d = 1'b0;
            dmem_write_en_d = 1'b0;
            // Writeback stage
            reg_writedata_sel_d = 1;
        end

        7'h13: begin // I-Type Arithmetic Instructions
            // Decode stage
            immgen_en_d = 1;
            reg_read_addr1_d = rs1;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b01;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 0;
            pcadder_in2_sel_d = 0;
            pcadder_out_sel_d = 1;
            pcadder_out_merge_sel_d = 0;
            alu_en_d = 1;

        if (funct3 == 3'b000) begin
            alu_op_d = 5'd11; // ADDI
        end
        else if (funct3 == 3'b111) begin
            alu_op_d = 5'd12; // ANDI
        end
        else if (funct3 == 3'b110) begin
            alu_op_d = 5'd13; // ORI
        end
        else if (funct3 == 3'b100) begin
            alu_op_d = 5'd14; // XORI
        end
        else if (funct3 == 3'b010) begin
            alu_op_d = 5'd15; // SLTI
        end
        else if (funct3 == 3'b011) begin
            alu_op_d = 5'd16; // SLTIU
        end
        else if (funct3 == 3'b101) begin
            if (funct7 == 7'b0000000) begin
                alu_op_d = 5'd18; // SRLI
            end
            else if (funct7 == 7'b0100000) begin
                alu_op_d = 5'd17; // SRAI
            end
        end
        else if (funct3 == 3'b001) begin
            if (funct7 == 7'b0000000) begin
                alu_op_d = 5'd19; // SLLI
            end
        end

            alu_mul_data2_sel_d = 1;
            mul_en_d = 0;
            execute_out_sel_d = 2'b01;
            // Memory stage
            dmem_read_en_d = 0;
            dmem_write_en_d = 0;
            // Writeback stage
            reg_writedata_sel_d = 1;
        end

        7'h03: begin // Load (LW)
            // Decode stage
            immgen_en_d = 1;
            reg_read_addr1_d = rs1;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b01;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 1'b0;
            pcadder_in2_sel_d = 1'b0;
            pcadder_out_sel_d = 1'b0;
            pcadder_out_merge_sel_d = 1'b0;
            alu_en_d = 1;
            alu_op_d = 5'b10101;
            alu_mul_data2_sel_d = 1;
            mul_en_d = 0;
            execute_out_sel_d = 2'b01;
            // Memory stage
            dmem_read_en_d = 1;
            dmem_write_en_d = 0;
            // Writeback stage
            reg_writedata_sel_d = 0;
        end

        7'h23: begin // Store (SW)
            // Decode stage
            immgen_en_d = 1;
            reg_read_addr1_d = rs1;
            reg_read_addr2_d = rs2;
            reg_write_addr_d = 5'd0;
            reg_read_en_d = 2'b11;
            reg_write_en_d = 0;
            // Execute stage
            pcadder_in1_sel_d = 1'b0;
            pcadder_in2_sel_d = 1'b0;
            pcadder_out_sel_d = 1'b0;
            pcadder_out_merge_sel_d = 1'b0;
            alu_en_d = 1;
            alu_op_d = 5'b10110;
            alu_mul_data2_sel_d = 1;
            mul_en_d = 0;
            execute_out_sel_d = 2'b01;
            // Memory stage
            dmem_read_en_d = 0;
            dmem_write_en_d = 1;
            // Writeback stage
            reg_writedata_sel_d = 1'b0;
        end

        7'h63: begin // Branch
            // Decode stage
            immgen_en_d = 1;
            reg_read_addr1_d = rs1;
            reg_read_addr2_d = rs2;
            reg_write_addr_d = 5'd0;
            reg_read_en_d = 2'b11;
            reg_write_en_d = 0;
            // Execute stage
            pcadder_in1_sel_d = 0;
            pcadder_in2_sel_d = 0;
            pcadder_out_sel_d = 0;
            pcadder_out_merge_sel_d = 0;
            alu_en_d = 1;

            if (funct3 == 3'b000) alu_op_d = 5'd23; // BEQ
            else if (funct3 == 3'b001) alu_op_d = 5'd24; // BNE
            else if (funct3 == 3'b100) alu_op_d = 5'd25; // BLT (signed)
            else if (funct3 == 3'b101) alu_op_d = 5'd26; // BGE (signed)
            else if (funct3 == 3'b110) alu_op_d = 5'd27; // BLTU (unsigned)
            else if (funct3 == 3'b111) alu_op_d = 5'd28; // BGEU (unsigned)
            else alu_op_d = 5'd0; // default NOP

            alu_mul_data2_sel_d = 0;
            mul_en_d = 0;
            execute_out_sel_d = 2'b00;
            // Memory stage
            dmem_read_en_d = 1'b0;
            dmem_write_en_d = 1'b0;
            // Writeback stage
            reg_writedata_sel_d = 1'b0;
        end

        7'h6F: begin // JAL
            // Decode stage
            immgen_en_d = 1'b1;
            reg_read_addr1_d = 5'd0;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b00;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 0;
            pcadder_in2_sel_d = 0;
            pcadder_out_sel_d = 0;
            pcadder_out_merge_sel_d = 0;
            alu_en_d = 1;;
            alu_op_d = 5'b11110;
            alu_mul_data2_sel_d = 1'b1;
            mul_en_d = 0;
            execute_out_sel_d = 2'b11;
            // Memory stage
            dmem_read_en_d = 0;
            dmem_write_en_d = 0;
            // Writeback stage
            reg_writedata_sel_d = 1;
        end

        7'h67: begin // JALR
            // Decode stage
            immgen_en_d = 1;
            reg_read_addr1_d = rs1;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b01;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 0;
            pcadder_in2_sel_d = 0;
            pcadder_out_sel_d = 1;
            pcadder_out_merge_sel_d = 0;
            alu_en_d = 1;
            alu_op_d = 5'b11111;
            alu_mul_data2_sel_d = 1'b1;
            mul_en_d = 0;
            execute_out_sel_d = 2'b11;
            // Memory stage
            dmem_read_en_d = 0;
            dmem_write_en_d = 0;
            // Writeback stage
            reg_writedata_sel_d = 1;
        end

        7'h37: begin // LUI
            // Decode stage
            immgen_en_d = 1;
            reg_read_addr1_d = 5'd0;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b00;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 1'b0;
            pcadder_in2_sel_d = 1'b0;
            pcadder_out_sel_d = 1'b0;
            pcadder_out_merge_sel_d = 1'b0;
            alu_en_d = 1;
            alu_op_d = 5'b10100;
            alu_mul_data2_sel_d = 1'b1;
            mul_en_d = 0;
            execute_out_sel_d = 2'b01;
            // Memory stage
            dmem_read_en_d = 0;
            dmem_write_en_d = 0;
            // Writeback stage
            reg_writedata_sel_d = 1;
        end

        7'h17: begin // AUIPC
            // Decode stage 
            immgen_en_d = 1;
            reg_read_addr1_d = 5'd0;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = rd;
            reg_read_en_d = 2'b00;
            reg_write_en_d = 1;
            // Execute stage
            pcadder_in1_sel_d = 0;
            pcadder_in2_sel_d = 0;
            pcadder_out_sel_d = 0;
            pcadder_out_merge_sel_d = 1;
            alu_en_d = 1'b0;
            alu_op_d = 5'b11101;
            alu_mul_data2_sel_d = 1'b0;
            mul_en_d = 1'b0;
            execute_out_sel_d = 2'b00;
            // Memory stage
            dmem_read_en_d = 0;
            dmem_write_en_d = 0;
            // Writeback stage
            reg_writedata_sel_d = 1;
        end

        default: begin
            immgen_en_d = 0;
            reg_read_addr1_d = 5'd0;
            reg_read_addr2_d = 5'd0;
            reg_write_addr_d = 5'd0;
            reg_read_en_d = 2'b00;
            reg_write_en_d = 0;
            pcadder_in1_sel_d = 0;
            pcadder_in2_sel_d = 0;
            pcadder_out_sel_d = 0;
            pcadder_out_merge_sel_d = 0;
            alu_en_d = 0;
            alu_op_d = 0;
            alu_mul_data2_sel_d = 0;
            mul_en_d = 0;
            execute_out_sel_d = 2'b00;
            dmem_read_en_d = 0;
            dmem_write_en_d = 0;
            reg_writedata_sel_d = 0;
        end
    endcase
end

endmodule