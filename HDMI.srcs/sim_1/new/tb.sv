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
    repeat(5) @(posedge clk);
    
    write('b10100101, 'b10011001);
    repeat(20) @(posedge clk);    
    write('b00110011, 'b01100001);
    
    repeat(50) @(posedge clk);
    $finish;
end

task write(input [7:0] address, input [7:0] data);
    rw = 0;
    data_address = address;
    wdata = data;
    wvalid = 1;
    @(posedge clk);
    wvalid = 0;
    
    // receive slave address
    repeat(9) @(posedge scl);
    
    // slave address ack
    force sda = 0;
    @(negedge scl);
    release sda;
    
    // receive data address
    repeat(9) @(posedge scl);
    
    // data address ack
    force sda = 0;
    @(negedge scl);
    release sda;
    
    // receive data
    repeat(9) @(posedge scl);
    
    // data ack
    force sda = 0;
    @(negedge scl);
    release sda;
    
    @(negedge busy);
endtask

endmodule
