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
    output logic impulse_p,
    output logic impulse_n,
    output logic impulse_0,
    output logic impulse_1
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
    if (rst) begin
        impulse_p <= 0;
        impulse_n <= 0;
        impulse_0 <= 0;
        impulse_1 <= 0;
    end
    else begin
        impulse_p <= (counter == div / 2);
        impulse_n <= (counter == 0);
        impulse_0 <= (counter == div / 4);
        impulse_1 <= (counter == div * 3 / 4);
    end    

endmodule
