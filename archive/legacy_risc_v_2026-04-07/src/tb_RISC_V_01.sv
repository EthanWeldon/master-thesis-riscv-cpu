module tb_RISC_V_01;

    // Clock and Reset
    logic clk;
    logic reset;
    
    // Instruction Memory Read Enable
    logic imem_read_en;
    
    // Instantiate the RISC-V core
    RISC_V_01 riscv_core (
        .clk(clk),
        .reset(reset),
        .imem_read_en(imem_read_en)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end
    
    // Testbench stimulus
    initial begin
        reset = 1; // Assert reset
        imem_read_en = 1; // Enable instruction memory read
        #10; // Wait for a few clock cycles
        reset = 0; // Deassert reset
    
        // Add more test cases as needed
    
        #100; // Run for a while before finishing the simulation
        $finish; // End the simulation
    end

endmodule