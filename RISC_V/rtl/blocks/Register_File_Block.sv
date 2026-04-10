module Register_File_Block (
  // Inputs from Decode Stage
  input  logic        clk,                //clock
  input  logic [4:0]  reg_read_addr1_d,   // rs1
  input  logic [4:0]  reg_read_addr2_d,   // rs2
  input  logic [1:0]  reg_read_en_d,      // {rs2_en, rs1_en}
  input  logic [4:0]  reg_write_addr_d,   // rd
  input  logic        reg_write_en_d,     // write enable
  input  logic [31:0] writeData,          // data to write from WB stage

  // Read outputs
  output logic [31:0] reg_readdata1_d,
  output logic [31:0] reg_readdata2_d
);

  // Internal register file
  logic [31:0] regFile [0:31];

  // Combinational reads with read enables
  assign reg_readdata1_d = (reg_read_en_d[0] && reg_read_addr1_d != 5'd0)
               ? regFile[reg_read_addr1_d] : 32'd0;

  assign reg_readdata2_d = (reg_read_en_d[1] && reg_read_addr2_d != 5'd0)
               ? regFile[reg_read_addr2_d] : 32'd0;

  // Controlled write (no clk/reset used)
  always_ff @ (posedge clk) begin
    if (reg_write_en_d && reg_write_addr_d != 5'd0) begin
      regFile[reg_write_addr_d] <= writeData;
    end
    // Always enforce x0 as zero
    regFile[0] <= 32'd0;
  end

endmodule