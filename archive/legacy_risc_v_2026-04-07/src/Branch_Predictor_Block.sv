module Branch_Predictor_Block(
    //inputs
    input clk, rst,
    input [1:0] pc_branch_en_sel,
    input [31:0] pc_f, pc_d, instr_f, pc_branch,

    //outputs
    output logic flush_fd, flush_de,
    output logic [31:0] pc_out
);

    //internal wires
    logic [31:0] pc_old1, pc_old2;
    logic [1:0] state, nextstate;

    //state memory
    always_ff @(posedge clk) begin
    state <= (rst) ? 2'b00 : nextstate;
    pc_old1 <= (rst) ? 32'h0000_0000 : pc_f;
    pc_old2 <= (rst) ? 32'h0000_0000 : pc_old1;
    end

    //nextstate comb logic
    always_comb begin
        //by default have nextstate = state
        nextstate = state;
        //by default have pc_out = pc_f + 4
        pc_out = pc_f + 4;
        //3 different types of instructions
        case(instr_f[6:0])
            //JAL
            7'b1101111: begin
                pc_out = pc_f + {{11{instr_f[31]}}, instr_f[31], instr_f[19:12], instr_f[20], instr_f[30:21], 1'b0};
                nextstate = state;
            end
            //Branch
            7'b1100011: begin
                case(state)
                    2'b00: pc_out = pc_f + 4; //failure
                    2'b01: pc_out = pc_f + 4; //failure
                    2'b10: pc_out = pc_f + $signed({{19{instr_f[31]}}, instr_f[31], instr_f[7], instr_f[30:25], instr_f[11:8], 1'b0});
                    2'b11: pc_out = pc_f + $signed({{19{instr_f[31]}}, instr_f[31], instr_f[7], instr_f[30:25], instr_f[11:8], 1'b0});

                endcase
            end
        endcase

        //3 different pc_branch_en_sel options
        case(pc_branch_en_sel)
            //execute says no branch
             2'b01: begin
                //if we predicted success but got failure
                if (pc_d == pc_branch) begin
                    //flush and load pc_old2, decrement nextstate
                    flush_de = 1;
                    flush_fd = 1;
                    pc_out = pc_old2;
                    if (state != 2'b00) begin
                        nextstate = state - 2'b01;
                    end
                end
                //if we predicted failure and got failure
                if (pc_d != pc_branch) begin
                    //no flush, increment nextstate
                    flush_fd = 0;
                    flush_de = 0;
                    if (state != 2'b00) begin
                        nextstate = state - 2'b01;
                    end
                end
             end
             2'b10: begin
                //if we predicted failure but got success
                if (pc_d != pc_branch) begin
                    //flush, load pc_branch, decrement nextstate
                    flush_fd = 1;
                    flush_de = 1;
                    pc_out = pc_branch;
                    if (state != 2'b11) begin
                        nextstate = state + 2'b01;
                    end
                end
                //if we predicted success and got success
                if (pc_d == pc_branch) begin
                    //no flush, increment state
                    flush_fd = 0;
                    flush_de = 0;
                    if (state != 2'b11) begin
                        nextstate = state + 2'b01;
                    end
                end
             end
             default: begin
                //no flush, no change in nextstate = state, no pc_out change
                flush_fd = 0;
                flush_de = 0;
                nextstate = state;
             end
        endcase
    end
endmodule