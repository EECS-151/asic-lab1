module simple_counter (
    input  logic       clk,
    input  logic       reset,
    output logic [1:0] counter_out
);
    logic [1:0] counter;

    always_ff @(________ or ________) begin
        if (____) begin // TODO
            counter <= 2'b00;
        end else begin
            case (____) // TODO
                // TODO
            endcase
        end
    end

    ____ counter_out = ____; // TODO
endmodule
