`timescale 1ns / 1ps

module video_generator (
    input clk,
    input rst,
    input start,
    output data_clk,
    output [15:0] data,
    output logic de,
    output logic hsync,
    output logic vsync
);

assign data_clk = clk;

localparam image_width = 800;
localparam image_height = 480;

logic functioning;

wire [11:0] x, y;
wire gen_de, gen_hsync, gen_vsync;
wire [7:0] Y, Cb, Cr;

logic [7:0] data_Y;
logic [7:0] data_CbCr;

assign data = {data_Y, data_CbCr};

always @(posedge clk, posedge rst) begin
    if (rst)
        functioning <= 0;
    else if (start)
        functioning <= 1;
end

sync_generator #(.hdata(image_width), .vdata(image_height)) sync_generator(
    .clk(clk), .rst(rst), .enabled(functioning),
    .x(x), .y(y), .de(gen_de), .hsync(gen_hsync), .vsync(gen_vsync)
);

color_selector #(.image_width(image_width), .image_height(image_height)) color_selector(
    .clk(clk), .x(x), .y(y),
    .Y(Y), .Cb(Cb), .Cr(Cr)
);

wire oddPixel = x[0];

always @(posedge clk) begin
    data_Y <= Y;
    data_CbCr <= !oddPixel ? Cb : Cr;

    de <= gen_de;
    hsync <= gen_hsync;
    vsync <= gen_vsync;
end

endmodule
