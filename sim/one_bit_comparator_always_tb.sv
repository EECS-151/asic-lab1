`timescale 1ns/1ns

`define SECOND  1000000000
`define MS      1000000

module one_bit_comparator_always_tb;
    logic a, b;
    logic greater, less, equal;

    one_bit_comparator_always DUT (
        .a(a),
        .b(b),
        .greater(greater),
        .less(less),
        .equal(equal)
    );

    initial begin
        `ifdef IVERILOG
            $dumpfile("one_bit_comparator_always_tb.fst");
            $dumpvars(0, one_bit_comparator_always_tb);
        `else
            $vcdpluson;
        `endif

        a = 1'b0;
        b = 1'b0;
        #1ns;
        assert (!greater && !less && equal)
            else $fatal(1, "a=0 b=0 expected equal=1");        

        a = 1'b0;
        b = 1'b1;
        #1ns;
        assert (!greater && less && !equal)
            else $fatal(1, "a=0 b=1 expected less=1");

        a = 1'b1;
        b = 1'b0;
        #1ns;
        assert (greater && !less && !equal)
            else $fatal(1, "a=1 b=0 expected greater=1");

        a = 1'b1;
        b = 1'b1;
        #1ns;
        assert (!greater && !less && equal)
            else $fatal(1, "a=1 b=1 expected equal=1");

        $display("All tests passed!");

        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
