module Immediate_Generator_Block (
  input  logic [31:0] instruction,   // Full instruction
  input  logic        immgen_en_d,   // Enable signal from Control Unit
  output logic [31:0] imm_out        // Sign-extended immediate
);

  logic [31:0] imm;

  always_comb begin
    imm = 32'd0;

    if (immgen_en_d) begin
      case (instruction[6:0])
        7'b0010011, 7'b0000011, 7'b1100111: begin
          // I-type
          imm = { {20{instruction[31]}}, instruction[31:20] };
        end

        7'b0100011: begin
          // S-type
          imm = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
        end

        7'b1100011: begin
          // B-type 
          imm = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        end

        7'b0010111, 7'b0110111: begin
          // U-type
          imm = { instruction[31:12], 12'd0 };
        end

        7'b1101111: begin
          // J-type
          imm = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
        end

        default: begin
          imm = 32'd0;
        end
      endcase
    end
  end

  assign imm_out = imm;

endmodule
