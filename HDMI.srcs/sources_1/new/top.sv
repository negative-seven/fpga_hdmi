`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2023 12:15:04 PM
// Design Name: 
// Module Name: top
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

video_generator video_generator(
    .clk(clk), .rst(rst), .start(setup_finished),
    .data_clk(hd_clk), .data(hd_data), .de(hd_de), .hsync(hd_hsync), .vsync(hd_vsync)
);

endmodule
