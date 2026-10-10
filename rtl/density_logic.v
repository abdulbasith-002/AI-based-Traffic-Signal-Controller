`timescale 1ns/1ps
// Converts a vehicle count into a compact density class.
// 00 = low (0..9), 01 = medium (10..29), 10 = high (30+).
module density_logic (
    input wire [7:0] vehicle_count,
    output reg [1:0] vehicle_density
);
    always @* begin
        if (vehicle_count < 8'd10)
            vehicle_density = 2'b00;
        else if (vehicle_count < 8'd30)
            vehicle_density = 2'b01;
        else
            vehicle_density = 2'b10;
    end
endmodule
