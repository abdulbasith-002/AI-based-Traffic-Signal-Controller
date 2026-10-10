`timescale 1ns/1ps
// Top-level integration of the traffic FSM and programmable timer.
module traffic_system_top_final (
    input wire clk,
    input wire reset,
    input wire [1:0] vehicle_density,
    input wire pedestrian_request,
    output wire red,
    output wire yellow,
    output wire green,
    output wire pedestrian_active
);
    wire [31:0] timer_limit;
    wire timer_expired;

    traffic_fsm_final controller (
        .clk(clk), .reset(reset), .timer_expired(timer_expired),
        .vehicle_density(vehicle_density), .pedestrian_request(pedestrian_request),
        .timer_limit(timer_limit), .red(red), .yellow(yellow), .green(green),
        .pedestrian_active(pedestrian_active)
    );

    traffic_timer #(.WIDTH(32)) timer_unit (
        .clk(clk), .reset(reset), .timer_limit(timer_limit),
        .timer_expired(timer_expired)
    );
endmodule
