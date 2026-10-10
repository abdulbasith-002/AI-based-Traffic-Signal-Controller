`timescale 1ns/1ps
// Reusable programmable timer. timer_limit is measured in clock cycles.
module traffic_timer #(
    parameter WIDTH = 32
)(
    input wire clk,
    input wire reset,
    input wire [WIDTH-1:0] timer_limit,
    output reg timer_expired
);
    reg [WIDTH-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter       <= {WIDTH{1'b0}};
            timer_expired <= 1'b0;
        end else begin
            timer_expired <= 1'b0; // one-clock pulse
            if (timer_limit == 0) begin
                counter       <= {WIDTH{1'b0}};
                timer_expired <= 1'b1;
            end else if (counter >= timer_limit - 1'b1) begin
                counter       <= {WIDTH{1'b0}};
                timer_expired <= 1'b1;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule
