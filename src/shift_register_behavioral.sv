module shift_register_behavioral (
    input  logic       in,
    input  logic       clk,
    output logic [3:0] out
);
    logic [3:0] shift_reg;

    always_ff @(posedge clk) begin
        // TODO
    end

    ____ out = ____; // TODO
endmodule
