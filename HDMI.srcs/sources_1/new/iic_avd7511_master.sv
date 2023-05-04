`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2023 12:15:04 PM
// Design Name: 
// Module Name: iic_avd7511_master
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


module iic_avd7511_master #(parameter clk_div=1000) (
    input clk,
    input rst,
    output scl,
    inout sda,
    input rw, // read = 1, write = 0
    input [6:0] data_address,
    input [7:0] wdata,
    input wvalid,
    output logic [7:0] rdata,
    output rvalid,
    output logic busy
    );

enum {Idle, SendStart, SendSlaveAddress, SendRW, ReceiveAck, SendDataAddress, SendData, ReceiveData, SendStop} states;

states state;
states next_state;
logic latched_rw;
logic [6:0] latched_data_address;
logic [7:0] latched_wdata;
logic latched_wvalid; // TODO: initialize
logic latched_ack; // TODO: initialize
logic [3:0] shift_counter; // TODO: initialize
logic data_address_sent; // TODO: initialize

clock_divider #(.div(clk_div)) divider (.clk(clk), .rst(rst), .slow_clk(slow_clk), .enable(state_enable));


always @(posedge clk) begin
    if (wvalid) begin
        latched_rw <= rw;
        latched_data_address <= data_address;
        latched_wdata <= wdata;
        latched_wvalid <= 1; // TODO: set back to 0
    end
end

always @(posedge clk, posedge rst)
    if (rst)
        state <= Idle;
    else if (state_enable)
        state <= next_state;

wire shift_completed = shift_counter == 0;

always @* begin
    next_state <= Idle;
    case (state)
        Idle: if (latched_wvalid) next_state = SendStart;
        SendStart: next_state = SendSlaveAddress;
        SendSlaveAddress: next_state = shift_completed ? SendRW : SendSlaveAddress;
        SendRW: next_state = ReceiveAck;
        ReceiveAck: 
            if (latched_ack)
                next_state = data_address_sent ? ReceiveData : SendDataAddress;
            else
                next_state = SendStop;
    endcase
end

endmodule
