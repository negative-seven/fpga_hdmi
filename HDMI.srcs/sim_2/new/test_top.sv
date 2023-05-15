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
logic start;
logic [7:0] leds;
tri1 hd_sda;

top #(10) top_instance (.clk(clk), .rst(rst), .start(start), .hd_scl(hd_scl), .hd_sda(hd_sda), .leds(leds));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;
    
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_write();
    respond_to_read();
end

task respond_to_write();
    // slave address ack
    repeat(9) @(posedge hd_scl);
    force hd_sda = 0;
    @(negedge hd_scl);
    release hd_sda;
    
    // data address ack
    repeat(9) @(posedge hd_scl);
    force hd_sda = 0;
    @(negedge hd_scl);
    release hd_sda;
    
    // data ack
    repeat(9) @(posedge hd_scl);
    force hd_sda = 0;
    @(negedge hd_scl);
    release hd_sda;
    
    @(posedge hd_scl);
endtask

task respond_to_read();
    // slave address ack
    repeat(9) @(posedge hd_scl);
    force hd_sda = 0;
    @(negedge hd_scl);
    release hd_sda;
    
    // data address ack
    repeat(9) @(posedge hd_scl);
    force hd_sda = 0;
    @(negedge hd_scl);
    release hd_sda;
    
    // slave address ack
    repeat(10) @(posedge hd_scl);
    force hd_sda = 0;
    @(negedge hd_scl);
    release hd_sda;
    
    // data ack
    @(posedge hd_scl) force hd_sda = 1;
    @(posedge hd_scl) force hd_sda = 1;
    @(posedge hd_scl) force hd_sda = 0;
    @(posedge hd_scl) force hd_sda = 1;
    @(posedge hd_scl) force hd_sda = 1;
    @(posedge hd_scl) force hd_sda = 0;
    @(posedge hd_scl) force hd_sda = 0;
    @(posedge hd_scl) force hd_sda = 1;
    @(posedge hd_scl) release hd_sda;
    
    @(posedge hd_scl);
endtask

endmodule
