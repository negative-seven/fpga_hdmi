`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2023 10:05:32 AM
// Design Name: 
// Module Name: test_top
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


module test_top;

logic clk;
logic rst;

top #(4) top_instance (.clk(clk), .rst(rst), .start(start), .hd_scl(hd_scl), .hd_sda(hd_sda));

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

endmodule
