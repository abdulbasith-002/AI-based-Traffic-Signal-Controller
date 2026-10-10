`timescale 1ns/1ps
module traffic_system_tb_final;
    reg clk, reset;
    reg [1:0] vehicle_density;
    reg pedestrian_request;
    wire red, yellow, green, pedestrian_active;

    // Short values keep the simulation quick; RTL defaults are used in hardware.
    traffic_system_top_final dut (
        .clk(clk), .reset(reset), .vehicle_density(vehicle_density),
        .pedestrian_request(pedestrian_request), .red(red), .yellow(yellow),
        .green(green), .pedestrian_active(pedestrian_active)
    );

    initial begin clk = 1'b0; forever #5 clk = ~clk; end

    initial begin
        $dumpfile("traffic_system.vcd");
        $dumpvars(0, traffic_system_tb_final);
        $display("time reset density ped_req | R Y G PED");
        $monitor("%0t    %b      %b      %b     | %b %b %b  %b",
                 $time, reset, vehicle_density, pedestrian_request,
                 red, yellow, green, pedestrian_active);
        reset = 1'b1; vehicle_density = 2'b00; pedestrian_request = 1'b0;
        #20; reset = 1'b0;
        #80; vehicle_density = 2'b01;
        #80; vehicle_density = 2'b10;
        #20; pedestrian_request = 1'b1;
        #10; pedestrian_request = 1'b0;
        #300;
        $finish;
    end

    // Basic safety assertions: never allow green and yellow together;
    // pedestrian phase must show red vehicle light.
    always @(negedge clk) begin
        if (!reset) begin
            if (green && yellow) begin
                $display("ERROR: green and yellow simultaneously active");
                $fatal;
            end
            if (pedestrian_active && !red) begin
                $display("ERROR: pedestrian phase without red light");
                $fatal;
            end
        end
    end
endmodule
