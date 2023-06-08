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

localparam screen_width = 800;
localparam screen_height = 480;
localparam image_width = 200;
localparam image_height = 120;

logic functioning;

wire [11:0] x, y;
wire gen_de, gen_hsync, gen_vsync;
wire [7:0] Y, Cb, Cr;

logic [7:0] data_Y;
logic [7:0] data_CbCr;

assign data[15:8] = data_Y;
assign data[7:0] = data_CbCr;

always @(posedge clk, posedge rst) begin
    if (rst)
        functioning <= 0;
    else if (start)
        functioning <= 1;
end

sync_generator #(.hdata(screen_width), .vdata(screen_height)) sync_generator(
    .clk(clk), .rst(rst), .enabled(functioning),
    .x(x), .y(y), .de(gen_de), .hsync(gen_hsync), .vsync(gen_vsync)
);

// static_image_color_selector #(
//     .scale_factor(4),
//     .image_width(image_width), .image_height(image_height)
// ) static_color_selector(
//     .clk(clk), .rst(rst),
//     .x(x), .y(y),
//     .Y(Y), .Cb(Cb), .Cr(Cr)
// );

bouncing_image_color_selector #(
    .screen_width(screen_width), .screen_height(screen_height),
    .image_width(image_width), .image_height(image_height)
) bouncing_color_selector(
    .clk(clk), .rst(rst),
    .x(x), .y(y),
    .Y(Y), .Cb(Cb), .Cr(Cr)
);

logic oddPixel = x[0];

always @(posedge clk) begin
    data_Y <= Y;
    data_CbCr <= !oddPixel ? Cb : Cr;

    oddPixel <= x[0];

    de <= gen_de;
    hsync <= gen_hsync;
    vsync <= gen_vsync;
end

endmodule
