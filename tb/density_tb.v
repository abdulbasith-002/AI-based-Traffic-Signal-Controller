`timescale 1ns/1ps
module density_tb;
    reg [7:0] vehicle_count;
    wire [1:0] vehicle_density;
    density_logic dut(.vehicle_count(vehicle_count), .vehicle_density(vehicle_density));
    initial begin
        $monitor("count=%0d -> density=%b", vehicle_count, vehicle_density);
        vehicle_count=0; #10;
        vehicle_count=9; #10;
        vehicle_count=10; #10;
        vehicle_count=29; #10;
        vehicle_count=30; #10;
        vehicle_count=255; #10;
        $finish;
    end
endmodule
