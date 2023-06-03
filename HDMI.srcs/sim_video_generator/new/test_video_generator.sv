`timescale 1ns / 1ps

module test_video_generator;

logic clk, rst;

video_generator video_generator(
    .clk(clk), .rst(rst), .start(start_generator),
    .data_clk(hd_clk), .data(hd_data), .de(hd_de), .hsync(hd_hsync), .vsync(hd_vsync)
);

endmodule
