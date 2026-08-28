`timescale 1ns/1ns

`define SECOND  1000000000
`define MS      1000000

module shift_register_behavioral_tb;
    logic       in;
    logic [3:0] prev_out;
    logic       clk = 1'b0;
    logic [3:0] out;

    shift_register_behavioral DUT (
        .in(in),
        .clk(clk),
        .out(out)
    );

    always #4ns clk <= ~clk;

    always_ff @(posedge clk)
        prev_out <= out;

    int i;

    initial begin
        `ifdef IVERILOG
            $dumpfile("shift_register_behavioral_tb.fst");
            $dumpvars(0, shift_register_behavioral_tb);
        `else
            $vcdpluson;
        `endif

        in = 1'b0;
        #32ns;
        assert (out == 4'b0000)
            else $fatal(1, "Initial state failed: out=%b", out);

        for(i = 0; i < 16; i = i++) begin
            in = $urandom_range(1, 0);
            #8ns;
            assert (out == {prev_out[2:0], in})
                else $fatal(1,
                "Shift failed: prev_out=%b in=%b out=%b expected=%b",
                prev_out, in, out, {prev_out[2:0], in});
        end

        $display("All tests passed!");

        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
