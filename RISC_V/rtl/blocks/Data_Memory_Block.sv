module Data_Memory_Block (
    input mem_write,         // Control signal: 1 = Write, 0 = Read
    input mem_read,          // Control signal: 1 = Read, 0 = No Read
    input [31:0] address,    // Memory address (byte addressable)
    input [31:0] write_data, // Data to write into memory
    output reg [31:0] read_data // Data read from memory
);

    integer memory_size = 4000;

    // Define 1000 words (32-bit each) = 4000 bytes of memory
    reg [7:0] data_memory [0:4000]; // 4000 bytes of memory

    // 10-bit word index from byte address (bits 2-11)
    logic [31:0] widx;

    initial begin
        for (int i = 0; i < memory_size; i = i + 1)
                 data_memory[i] = $urandom();
    end

    // Read operations (combinational logic)
    always @(*) begin
        read_data = 32'h0000_0000;   // default

        widx = address & 32'hFFFC;

        if (mem_read) begin
            if (widx < memory_size)  // Check bounds for 4000 words (0-3999)
                read_data = {data_memory[widx] ,
                               data_memory[widx + 1],
                               data_memory[widx + 2],
                               data_memory[widx + 3]};
            else
                read_data = 32'hDEAD_BEEF; // out-of-bounds signature
        end

        if (mem_write && (widx < memory_size)) begin
            data_memory[widx]  = write_data[31:24];
            data_memory[widx + 1] = write_data[23:16];
            data_memory[widx + 2] = write_data[15:8];
            data_memory[widx + 3] = write_data[7:0];
        end
    end

endmodule
