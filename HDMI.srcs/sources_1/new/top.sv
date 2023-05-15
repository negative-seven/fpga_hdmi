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
    
typedef struct packed {
    logic rw;
    logic [7:0] data_address;
    logic [7:0] wdata;
} transaction;
const transaction transactions [0:9] = '{
    '{0, 'h41, 0 << 6}, // set power-up
    '{0, 'h98, 'h03}, // required write, per documentation
    '{0, 'h9a, 'b11100000}, // required write, per documentation
    '{0, 'h9c, 'h30}, // required write, per documentation
    '{0, 'h9d, 'b01}, // required write, per documentation
    '{0, 'ha2, 'ha4}, // required write, per documentation
    '{0, 'ha3, 'ha4}, // required write, per documentation
    '{0, 'he0, 'hd0}, // required write, per documentation
    '{0, 'hf9, 'h00}, // required write, per documentation
    '{1, 'h00, 0} // read chip revision
};

typedef enum { Idle, StartTransaction, WaitForEndTransaction, Stop } states;
states state;
states next_state;

logic [$clog2($size(transactions) + 1) - 1:0] transaction_index;
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
        Idle: next_state = start ? StartTransaction : Idle;
        StartTransaction: next_state = WaitForEndTransaction;
        WaitForEndTransaction: 
            if (busy)
                next_state = WaitForEndTransaction;
            else
                next_state = transaction_index == $size(transactions) ? Stop : StartTransaction;
        Stop: next_state = Stop;
    endcase
end

always @(posedge clk, posedge rst) begin
    if (rst) begin
        transaction_index <= 0;
        state <= Idle;
        wvalid <= 0;
        leds <= 'b11111111;
    end
    else begin
        state <= next_state;
        case (state)
            StartTransaction: begin
                rw <= transactions[transaction_index].rw;
                data_address <= transactions[transaction_index].data_address;
                wdata <= transactions[transaction_index].wdata;
                wvalid <= 1;
                transaction_index <= transaction_index + 1;
            end
            WaitForEndTransaction: begin
                wvalid <= 0;
            end
            Stop: begin
                leds <= rdata;
            end
        endcase
    end
end
    
endmodule
