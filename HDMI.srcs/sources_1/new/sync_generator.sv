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


module sync_generator(
    input clk,
    input rst,
    input start,
    output [11:0] x,
    output [11:0] y,
    output logic de,
    output logic hsync,
    output logic vsync
);

localparam hData = 800;
localparam vData = 480;

localparam hfrontporch = 24;
localparam hsync_len = 72;
localparam hbackporch = 96;

localparam vfrontporch = 3;
localparam vsync_len = 7;
localparam vbackporch = 10;

localparam htotal = hfrontporch + hsync_len + hbackporch + hData;
localparam vtotal = vfrontporch + vsync_len + vbackporch + vData;

logic started;

always @(posedge clk, posedge rst)
    if (rst)
        started <= 0;
    else if (start)
        started <= 1;

logic [$clog2(htotal)-1:0] hcounter;
logic [$clog2(vtotal)-1:0] vcounter;

always @(posedge clk, posedge rst) begin
    if (rst) 
        hcounter <= 0;
    else if (hcounter == htotal - 1)
        hcounter <= 0;
    else if (started)
        hcounter <= hcounter + 1;
end

always @(posedge clk, posedge rst) begin
    if (rst) 
        vcounter <= 0;
    else if (vcounter == vtotal - 1)
        vcounter <= 0;
    else if (hcounter == htotal - 1)
        vcounter <= vcounter + 1;
end

assign x = hcounter - (htotal - hData);
assign y = vcounter - (vtotal - vData);

wire hactive = hcounter >= (htotal - hData);
wire vactive = vcounter >= (vtotal - vData);

always @(posedge clk, posedge rst) begin
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
