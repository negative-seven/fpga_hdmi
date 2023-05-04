`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2023 12:39:42 PM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider #(parameter div=2) (
    input clk,
    input rst,
    output logic slow_clk,
    output logic enable
    );

localparam divlen = $clog2(div);

logic [divlen-1:0] counter;

always @(posedge clk, posedge rst)
    if (rst)
        counter <= 0;
    else if (counter == div - 1)
        counter <= 0;
    else
        counter <= counter + 1;

always @(posedge clk, posedge rst)
    if (rst)
        slow_clk <= 0;
    else
        slow_clk <= (counter >= div / 2);

always @(posedge clk, posedge rst)
    if (rst)
        enable <= 0;
    else
        enable <= (counter == 0);

endmodule
