`timescale 1ns/1ps
// Optional wrapper when the input is a raw vehicle count rather than a density class.
module traffic_system_with_count (
    input wire clk,
    input wire reset,
    input wire [7:0] vehicle_count,
    input wire pedestrian_request,
    output wire red, yellow, green, pedestrian_active
);
    wire [1:0] vehicle_density;
    density_logic density_classifier (
        .vehicle_count(vehicle_count), .vehicle_density(vehicle_density)
    );
    traffic_system_top_final traffic_controller (
        .clk(clk), .reset(reset), .vehicle_density(vehicle_density),
        .pedestrian_request(pedestrian_request), .red(red), .yellow(yellow),
        .green(green), .pedestrian_active(pedestrian_active)
    );
endmodule
