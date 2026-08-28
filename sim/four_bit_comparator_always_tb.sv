`timescale 1ns/1ns

`define SECOND  1000000000
`define MS      1000000

module four_bit_comparator_always_tb;
    logic [3:0] a, b;
    logic greater, less, equal;

    four_bit_comparator_always DUT (
        .a(a),
        .b(b),
        .greater(greater),
        .less(less),
        .equal(equal)
    );

    int i;

    initial begin
        `ifdef IVERILOG
            $dumpfile("four_bit_comparator_always_tb.fst");
            $dumpvars(0, four_bit_comparator_always_tb);
        `else
            $vcdpluson;
        `endif

        for(i = 0; i < 16; i++) begin
            a = $urandom_range(15, 0);
            b = $urandom_range(15, 0);
            #1ns;
            if (a > b) begin
                assert (greater && !less && !equal)
                    else $fatal(1, "a=%0d b=%0d expected greater=1 less=0 equal=0 got g=%0b l=%0b e=%0b",
                                a, b, greater, less, equal);
            end else if (a < b) begin
                assert (!greater && less && !equal)
                    else $fatal(1, "a=%0d b=%0d expected greater=0 less=1 equal=0 got g=%0b l=%0b e=%0b",
                                a, b, greater, less, equal);
            end else begin
                assert (!greater && !less && equal)
                    else $fatal(1, "a=%0d b=%0d expected greater=0 less=0 equal=1 got g=%0b l=%0b e=%0b",
                                a, b, greater, less, equal);
            end
        end

        $display("All tests passed!");

        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
