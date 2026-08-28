module shift_register_structural (
    input  logic       in,
    input  logic       clk,
    output logic [3:0] out
);
    logic Q1, Q2, Q3, Q4;
    logic Q1n, Q2n, Q3n, Q4n;

    d_flip_flop dff_1(____, ____, ____, ____); // TODO
    d_flip_flop dff_2(____, ____, ____, ____); // TODO
    d_flip_flop dff_3(____, ____, ____, ____); // TODO
    d_flip_flop dff_4(____, ____, ____, ____); // TODO

    assign out = {____, ____, ____, ____}; // TODO
endmodule
