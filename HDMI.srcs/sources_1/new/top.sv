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
    output logic [7:0] leds
    );
    

typedef enum { Idle, Write, WaitAfterWrite, Read, WaitAfterRead, Stop } states;
states state;
states next_state;

logic rw;
logic [7:0] data_address;
logic [7:0] wdata;
logic wvalid;
logic [7:0] rdata;

iic_avd7511_master #(clkdiv) master (
    .clk(clk), .rst(rst),
    .scl(hd_scl), .sda(hd_sda),
    .rw(rw), .data_address(data_address), .wdata(wdata), .wvalid(wvalid), .rdata(rdata), .rvalid(rvalid), .busy(busy)
);

always @* begin
    next_state = Idle;
    case (state)
        Idle: next_state = start ? Write : Idle;
        Write: next_state = WaitAfterWrite;
        WaitAfterWrite: next_state = busy ? WaitAfterWrite : Read;
        Read: next_state = WaitAfterRead;
        WaitAfterRead: next_state = rvalid ? Stop : WaitAfterRead;
        Stop: next_state = Stop;
    endcase
end

always @(posedge clk, posedge rst) begin
    if (rst) begin
        state <= Idle;
        wvalid <= 0;
        leds <= 'b11111111;
    end
    else begin
        state <= next_state;
        case (state)
            Write: begin
                rw <= 0;
                data_address <= 'h45;
                wdata <= 'ha5;
                wvalid <= 1;
            end
            WaitAfterWrite: begin
                wvalid <= 0;
            end
            Read: begin
                rw <= 1;
                data_address <= 'h45;
                wvalid <= 1;
            end
            WaitAfterRead: begin
                wvalid <= 0;
            end
            Stop: begin
                leds <= rdata;
            end
        endcase
    end
end
    
endmodule
