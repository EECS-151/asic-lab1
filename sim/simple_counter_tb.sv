`timescale 1ns/1ns

`define SECOND  1000000000
`define MS      1000000

module simple_counter_tb;
    logic       reset = 1'b1;
    logic       clk = 1'b0;
    logic [1:0] counter;

    simple_counter DUT (
        .clk(clk),
        .reset(reset),
        .counter_out(counter)
    );

    always #4ns clk = ~clk;

    initial begin
        `ifdef IVERILOG
            $dumpfile("simple_counter_tb.fst");
            $dumpvars(0, simple_counter_tb);
        `else
            $vcdpluson;
        `endif

        #10ns;
        reset = 1'b0;

        assert (counter == 2'b00) else $fatal(1, "Expected 00 after reset deassert, got %b", counter);
        #4ns;
        assert (counter == 2'b01) else $fatal(1, "Expected 01, got %b", counter);
        #8ns;
        assert (counter == 2'b10) else $fatal(1, "Expected 10, got %b", counter);
        #8ns;
        assert (counter == 2'b11) else $fatal(1, "Expected 11, got %b", counter);
        #8ns;
        assert (counter == 2'b00) else $fatal(1, "Expected 00 wrap, got %b", counter);
        #8ns;
        assert (counter == 2'b01) else $fatal(1, "Expected 01, got %b", counter);

        #1ns;
        reset = 1'b1;
        #1ns;
        assert (counter == 2'b00) else $fatal(1, "Expected 00 after reset asserted, got %b", counter);

        $display("All tests passed!");

        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
