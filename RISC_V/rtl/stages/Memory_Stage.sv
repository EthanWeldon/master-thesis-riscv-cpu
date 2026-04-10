module Memory_Stage(
    // Inputs
    input logic [31:0] reg_readdata2_m,
    input logic [31:0] execute_out_m_in, 
    input logic [4:0] reg_write_addr_m_in,
    input logic dmem_read_en_m,
    input logic dmem_write_en_m,
    input logic reg_write_en_m_in,
    input logic reg_writedata_sel_m_in,
    
    // Outputs
    output logic [31:0] dmem_readdata_m,
    output logic [31:0] execute_out_m_out, 
    output logic [4:0] reg_write_addr_m_out,
    output logic reg_write_en_m_out,
    output logic reg_writedata_sel_m_out
);

Data_Memory_Block dmem (
    .mem_write(dmem_write_en_m),
    .mem_read(dmem_read_en_m),
    .address(execute_out_m_in), // Address is the output of the execute stage
    .write_data(reg_readdata2_m), // Data to write is from reg_readdata2
    .read_data(dmem_readdata_m) // Read data output
);

always_comb begin
    // Pass through the outputs
    execute_out_m_out = execute_out_m_in; 
    reg_write_addr_m_out = reg_write_addr_m_in;
    reg_write_en_m_out = reg_write_en_m_in;
    reg_writedata_sel_m_out = reg_writedata_sel_m_in;
end

endmodule