module Forwarding_Unit_Block(
    //inputs
    input [4:0] reg_writeaddress_m,
    input [4:0] reg_readaddress1_e,
    input [4:0] reg_readaddress2_e,
    input [4:0] reg_writeaddress,

    //outputs
    output logic [1:0] alumul_data1_sel_e,
    output logic [1:0] alumul_forward_sel_e
);
    //alumul input mux control
    always_comb begin
        alumul_data1_sel_e = 2'b00;
        alumul_forward_sel_e = 2'b00;

        if (reg_writeaddress_m == reg_readaddress1_e) begin
            alumul_data1_sel_e = 2'b01;
        end
        if (reg_writeaddress_m == reg_readaddress2_e) begin
            alumul_forward_sel_e = 2'b01;
        end
        if (reg_writeaddress == reg_readaddress1_e) begin
            alumul_data1_sel_e = 2'b10;
        end
        if (reg_writeaddress == reg_readaddress2_e) begin
            alumul_forward_sel_e = 2'b10;
        end

        // New condition: prioritize the most recent value when reg_writeaddress and reg_writeaddress_m are the same
        if (reg_writeaddress == reg_writeaddress_m) begin
            if (reg_writeaddress == reg_readaddress1_e) begin
                alumul_data1_sel_e = 2'b01; // Most recent value
            end
            if (reg_writeaddress == reg_readaddress2_e) begin
                alumul_forward_sel_e = 2'b01; // Most recent value
            end
        end
    end
endmodule