`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2023 03:22:07 PM
// Design Name: 
// Module Name: sync_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sync_generator #(parameter 
    hdata = 800,
    vdata = 480
) (
    input clk,
    input rst,
    input enabled,
    output [11:0] x,
    output [11:0] y,
    output logic de,
    output logic hsync,
    output logic vsync
);

localparam hfrontporch = 24;
localparam hsync_len = 72;
localparam hbackporch = 96;

localparam vfrontporch = 3;
localparam vsync_len = 7;
localparam vbackporch = 10;

localparam htotal = hfrontporch + hsync_len + hbackporch + hdata;
localparam vtotal = vfrontporch + vsync_len + vbackporch + vdata;

logic [$clog2(htotal)-1:0] hcounter;
logic [$clog2(vtotal)-1:0] vcounter;

always @(posedge clk) begin
    if (rst) 
        hcounter <= 0;
    else if (hcounter == htotal - 1)
        hcounter <= 0;
    else if (enabled)
        hcounter <= hcounter + 1;
end

always @(posedge clk) begin
    if (rst) 
        vcounter <= 0;
    else if (vcounter == vtotal - 1)
        vcounter <= 0;
    else if (hcounter == htotal - 1)
        vcounter <= vcounter + 1;
end

wire hactive = hcounter >= (htotal - hdata);
wire vactive = vcounter >= (vtotal - vdata);

assign x = hactive ? hcounter - (htotal - hdata) : 0;
assign y = vactive ? vcounter - (vtotal - vdata) : 0;

always @(posedge clk) begin
    if (rst) begin
        de <= 0;
        hsync <= 0;
        vsync <= 0;
    end
    else begin
        de <= hactive && vactive;
        hsync <= (hcounter >= hfrontporch && hcounter < hfrontporch + hsync_len);
        vsync <= (vcounter >= vfrontporch && vcounter < vfrontporch + vsync_len);
    end
end

endmodule
