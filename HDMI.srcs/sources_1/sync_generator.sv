`timescale 1ns / 1ps

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

localparam hfrontporch = 8;
localparam hsync_len = 32;
localparam hbackporch = 40;

localparam vfrontporch = 12;
localparam vsync_len = 8;
localparam vbackporch = 6;

localparam htotal = hdata + hfrontporch + hsync_len + hbackporch;
localparam vtotal = vdata + vfrontporch + vsync_len + vbackporch;

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

wire hactive = hcounter < hdata;
wire vactive = vcounter < vdata;

assign x = hcounter;
assign y = vcounter;

always @(posedge clk) begin
    if (rst) begin
        de <= 0;
        hsync <= 0;
        vsync <= 0;
    end
    else begin
        de <= hactive && vactive;
        hsync <= (hcounter >= hdata + hfrontporch && hcounter < hdata + hfrontporch + hsync_len);
        vsync <= (vcounter >= vdata + vfrontporch && vcounter < vdata + vfrontporch + vsync_len);
    end
end

endmodule
