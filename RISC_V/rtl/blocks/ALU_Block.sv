module ALU_Block(reg_readdata1_e,alumul_data2,alu_op_e,alu_en_e,alu_out,pc_branch_en_sel);

    //io
    input [31:0] reg_readdata1_e,alumul_data2;
    input [4:0] alu_op_e;
    input alu_en_e;
    output logic [31:0] alu_out;
    output logic [1:0] pc_branch_en_sel;

    //initialize outputs
    initial begin
        alu_out = 32'h0000_0000;
        pc_branch_en_sel = 2'b00;
    end
    //alu logic
    always @(*) begin
        case (alu_op_e)
        5'b00001: begin 
            alu_out = reg_readdata1_e + alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // ADD 1
        5'b00010: begin 
            alu_out = reg_readdata1_e - alumul_data2; 
            pc_branch_en_sel = 2'b00;
        end // SUB 2
        5'b00011: begin 
            alu_out = reg_readdata1_e & alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // AND 3
        5'b00100: begin 
            alu_out = reg_readdata1_e | alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // OR 4
        5'b00101: begin 
            alu_out = reg_readdata1_e ^ alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // XOR 5
        5'b00110: begin 
            alu_out = ($signed(reg_readdata1_e) < $signed(alumul_data2)) ? 32'h0000_0001 : 32'h0000_0000; 
            pc_branch_en_sel = 2'b00; 
        end // SLT 6
        5'b00111: begin 
            alu_out = (reg_readdata1_e < alumul_data2) ? 32'h0000_0001 : 32'h0000_0000; 
            pc_branch_en_sel = 2'b00; 
        end // SLTU 7
        5'b01000: begin 
            alu_out = $signed(reg_readdata1_e) >>> alumul_data2[4:0]; 
            pc_branch_en_sel = 2'b00; 
        end // SRA 8
        5'b01001: begin 
            alu_out = reg_readdata1_e >> alumul_data2[4:0]; 
            pc_branch_en_sel = 2'b00; 
        end // SRL 9
        5'b01010: begin 
            alu_out = reg_readdata1_e << alumul_data2[4:0]; 
            pc_branch_en_sel = 2'b00; 
        end // SLL 10
        5'b01011: begin 
            alu_out = reg_readdata1_e + alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // ADDI 11
        5'b01100: begin 
            alu_out = reg_readdata1_e & alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // ANDI 12
        5'b01101: begin 
            alu_out = reg_readdata1_e | alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // ORI 13
        5'b01110: begin 
            alu_out = reg_readdata1_e ^ alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // XORI 14
        5'b01111: begin 
            alu_out = ($signed(reg_readdata1_e) < $signed(alumul_data2)) ? 32'h0000_0001 : 32'h0000_0000; 
            pc_branch_en_sel = 2'b00; 
        end // SLTI 15
        5'b10000: begin 
            alu_out = (reg_readdata1_e < alumul_data2) ? 32'h0000_0001 : 32'h0000_0000; 
            pc_branch_en_sel = 2'b00; 
        end // SLTIU 16
        5'b10001: begin 
            alu_out = $signed(reg_readdata1_e) >>> alumul_data2[4:0]; 
            pc_branch_en_sel = 2'b00; 
        end // SRAI 17
        5'b10010: begin 
            alu_out = reg_readdata1_e >> alumul_data2[4:0]; 
            pc_branch_en_sel = 2'b00; 
        end // SRLI 18
        5'b10011: begin 
            alu_out = reg_readdata1_e << alumul_data2[4:0]; 
            pc_branch_en_sel = 2'b00; 
        end // SLLI 19
        5'b10100: begin 
            alu_out = alumul_data2; 
            pc_branch_en_sel = 2'b00; 
        end // LUI 20
        5'b10101: begin 
            alu_out = reg_readdata1_e + alumul_data2; // LW 21
            alu_out[1:0] = 2'b0; // set the last two bits to 0
            pc_branch_en_sel = 2'b00; 
        end
        5'b10110: begin 
            alu_out = reg_readdata1_e + alumul_data2; // SW 22
            alu_out[1:0] = 2'b0; // set the last two bits to 0
            pc_branch_en_sel = 2'b00; 
        end
        5'b10111: begin 
            pc_branch_en_sel = (reg_readdata1_e == alumul_data2) ? 2'b10 : 2'b01; 
        end // BEQ 23
        5'b11000: begin 
            pc_branch_en_sel = (reg_readdata1_e != alumul_data2) ? 2'b10 : 2'b01; 
        end // BNE 24
        5'b11001: begin 
            pc_branch_en_sel = ($signed(reg_readdata1_e) < $signed(alumul_data2)) ? 2'b10 : 2'b01; 
        end // BLT 25
        5'b11010: begin 
            pc_branch_en_sel = ($signed(reg_readdata1_e) >= $signed(alumul_data2)) ? 2'b10 : 2'b01; 
        end // BGE 26
        5'b11011: begin 
            pc_branch_en_sel = (reg_readdata1_e < alumul_data2) ? 2'b10 : 2'b01; 
        end // BLTU 27
        5'b11100: begin 
            pc_branch_en_sel = (reg_readdata1_e >= alumul_data2) ? 2'b10 : 2'b01; 
        end // BGEU 28
        5'b11101: begin 
            pc_branch_en_sel = 2'b01; 
        end // AUIPC 29
        5'b11110: begin 
            pc_branch_en_sel = 2'b10; 
        end // JAL 30
        5'b11111: begin 
            pc_branch_en_sel = 2'b10; 
        end // JALR 31
        default : begin
            alu_out = 32'h0000_0000;
            pc_branch_en_sel = 2'b00;
        end
        endcase
    end
endmodule