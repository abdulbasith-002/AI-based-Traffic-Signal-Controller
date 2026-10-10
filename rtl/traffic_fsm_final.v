`timescale 1ns/1ps
// Intelligent traffic controller FSM with vehicle-density timing and pedestrian priority.
module traffic_fsm_final #(
    parameter GREEN_LOW_TIME    = 32'd5,
    parameter GREEN_MEDIUM_TIME = 32'd10,
    parameter GREEN_HIGH_TIME   = 32'd20,
    parameter YELLOW_TIME       = 32'd3,
    parameter RED_TIME          = 32'd8,
    parameter PEDESTRIAN_TIME   = 32'd6
)(
    input wire clk,
    input wire reset,
    input wire timer_expired,
    input wire [1:0] vehicle_density,
    input wire pedestrian_request,
    output reg [31:0] timer_limit,
    output reg red,
    output reg yellow,
    output reg green,
    output reg pedestrian_active
);
    localparam [1:0] GREEN = 2'b00,
                     YELLOW = 2'b01,
                     RED = 2'b10,
                     PEDESTRIAN = 2'b11;

    reg [1:0] current_state, next_state;
    reg ped_request_latched;

    // Latch a request until it is served. Requests during the pedestrian phase
    // are intentionally not re-latched; a new request can be made afterward.
    always @(posedge clk or posedge reset) begin
        if (reset)
            ped_request_latched <= 1'b0;
        else if (current_state == PEDESTRIAN)
            ped_request_latched <= 1'b0;
        else if (pedestrian_request)
            ped_request_latched <= 1'b1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= RED;
        else
            current_state <= next_state;
    end

    always @* begin
        next_state = current_state;
        case (current_state)
            GREEN: if (timer_expired) next_state = YELLOW;
            YELLOW: if (timer_expired) next_state = RED;
            RED: if (timer_expired) begin
                if (ped_request_latched) next_state = PEDESTRIAN;
                else next_state = GREEN;
            end
            PEDESTRIAN: if (timer_expired) next_state = GREEN;
            default: next_state = RED;
        endcase
    end

    // Moore outputs: only one vehicle light is active at a time.
    always @* begin
        red = 1'b0;
        yellow = 1'b0;
        green = 1'b0;
        pedestrian_active = 1'b0;
        timer_limit = GREEN_LOW_TIME;
        case (current_state)
            GREEN: begin
                green = 1'b1;
                case (vehicle_density)
                    2'b00: timer_limit = GREEN_LOW_TIME;
                    2'b01: timer_limit = GREEN_MEDIUM_TIME;
                    default: timer_limit = GREEN_HIGH_TIME;
                endcase
            end
            YELLOW: begin yellow = 1'b1; timer_limit = YELLOW_TIME; end
            RED: begin red = 1'b1; timer_limit = RED_TIME; end
            PEDESTRIAN: begin
                red = 1'b1;
                pedestrian_active = 1'b1;
                timer_limit = PEDESTRIAN_TIME;
            end
            default: begin red = 1'b1; timer_limit = RED_TIME; end
        endcase
    end
endmodule
