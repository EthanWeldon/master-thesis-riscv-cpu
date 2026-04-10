module tb_RISC_V;

    // Clock and Reset
    logic clk;
    logic reset;

    // Instruction Memory Read Enable
    logic imem_read_en;

    // Output signals
    logic [31:0] reg_writedata;
    logic [4:0] reg_writeaddr;

    // Instantiate the RISC-V module
    RISC_V_02 risc_v_core (
        .clk(clk),
        .reset(reset),
        .imem_read_en(imem_read_en),
        // Outputs
        .reg_writedata(reg_writedata),
        .reg_writeaddr(reg_writeaddr)
    );

    // Clock generation with stop condition using outputs
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk; // 10 time units clock period
            if (reg_writedata == 1 && reg_writeaddr == 12) begin
                $finish; // Stop simulation when condition is met
            end
        end
    end

    // Reset generation
    initial begin
        reset = 1; imem_read_en = 1;
        #10; reset = 0; 
    end
endmodule