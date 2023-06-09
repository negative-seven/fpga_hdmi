`timescale 1ns / 1ps

module top #(parameter clkdiv = 1000) (
    input clk,
    input rst,
    input start,

    output hd_scl,
    inout hd_sda,
    
    output hd_clk,
    output [15:0] hd_data,
    output hd_de,
    output hd_hsync,
    output hd_vsync
);

logic setup_finished;

adv7511_setup #(.clk_div(clkdiv)) adv7511_setup(
    .clk(clk), .rst(rst),
    .start(start), .finished(setup_finished),
    .scl(hd_scl), .sda(hd_sda)
);

clk_wiz clock_wizard (.reset(rst), .clk_in1(clk), .clk_out1(video_clk), .locked(video_clk_locked));

video_generator video_generator(
    .clk(video_clk), .rst(rst), .start(setup_finished && video_clk_locked),
    .data_clk(hd_clk), .data(hd_data), .de(hd_de), .hsync(hd_hsync), .vsync(hd_vsync)
);

endmodule
