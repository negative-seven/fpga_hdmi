`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2023 12:55:20 PM
// Design Name: 
// Module Name: tb
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


module tb;

logic clk;
logic rst;

logic scl;
tri1 sda;
logic busy;

logic rw;
logic [7:0] data_address;
logic [7:0] wdata;
logic wvalid;

iic_avd7511_master #(.clk_div(20)) iic_master (
    .clk(clk),
    .rst(rst),
    .scl(scl),
    .sda(sda),
    .rw(rw),
    .data_address(data_address),
    .wdata(wdata),
    .wvalid(wvalid),
    .rdata(),
    .rvalid(),
    .busy(busy)
    );

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    repeat(2) @(posedge clk);
    rst = 0;
    repeat(2) @(posedge clk);
    
    // 0xa5 = 0x99
    rw = 0;
    data_address = 'ha5;
    wdata = 'h99;
    wvalid = 1;
    @(posedge clk);
    wvalid = 0;
    
    // ack
    repeat(9) @(posedge scl);
    force sda = 0;
    @(posedge scl);
    release sda;
    
    @(negedge busy);
    repeat(2) @(posedge scl);
    $finish;
end

endmodule
