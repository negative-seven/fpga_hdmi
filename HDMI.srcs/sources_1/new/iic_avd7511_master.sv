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
    input [7:0] data_address,
    input [7:0] wdata,
    input wvalid,
    output logic [7:0] rdata,
    output rvalid,
    output busy
    );

typedef enum {Idle, SendStart, NULL, SendStop,
            SendSlaveAddress, SendRW, ReceiveSlaveAddressAck,
            SendDataAddress, ReceiveDataAddressAck,
            SendData, ReceiveDataAck,
            ReceiveData, SendDataNack} states;

states state;
states next_state;
logic sda_z; // 1 = sda output is high impedance
logic sda_out; // signal outputted to sda if not in high impedance state
logic scl_high; // 1 = scl is held high, 0 = scl signal is assigned from slow clock
logic [7:1] latched_slave_address;
logic latched_rw;
logic [7:0] latched_data_address;
logic [7:0] latched_wdata;
logic latched_wvalid;
logic latched_ack;
logic [2:0] shift_counter;
logic data_address_sent = 0;

clock_divider #(.div(clk_div)) divider (.clk(clk), .rst(rst), .slow_clk(slow_clk), .impulse_0(scl_0), .impulse_1(scl_1), .impulse_n(scl_n));

assign sda = sda_z ? 'z : sda_out;
assign scl = scl_high ? 1 : slow_clk;

assign busy = state != Idle || latched_wvalid;

always @(posedge clk, posedge rst)
    if (rst) begin
        state <= Idle;
        scl_high <= 1;
    end
    else if (scl_n)
        state <= next_state;


always @(posedge clk) begin
    if (wvalid) begin
        latched_slave_address <= 'h72 >> 1; // PD/AD pin low
        latched_rw <= rw;
        latched_data_address <= data_address;
        latched_wdata <= wdata;
        latched_wvalid <= 1;
    end
end

wire shift_completed = (shift_counter == 0);

always @* begin
    next_state = Idle;
    case (state)
        Idle: if (latched_wvalid) next_state = SendStart;
        SendStart: next_state = SendSlaveAddress;
        SendSlaveAddress: next_state = shift_completed ? SendRW : SendSlaveAddress;
        SendRW: next_state = ReceiveSlaveAddressAck;
        ReceiveSlaveAddressAck: 
            if (!latched_ack) // ack
                next_state = data_address_sent ? ReceiveData : SendDataAddress;
            else // nack
                next_state = SendStop;
        SendDataAddress:
            if (shift_completed)
                next_state = ReceiveDataAddressAck;
            else
                next_state = SendDataAddress;
        ReceiveDataAddressAck:
            if (!latched_ack)
                next_state = latched_rw ? SendStart : SendData;
            else
                next_state = SendStop;
        SendData: next_state = shift_completed ? ReceiveDataAck : SendData;
        ReceiveDataAck: next_state = SendStop;
        ReceiveData: next_state = shift_completed ? SendDataNack : ReceiveData;
        SendDataNack: next_state = SendStop;
        SendStop: next_state = Idle;
    endcase
end

always @(posedge clk) begin
    if (scl_0) begin
        case (state)
            Idle: begin
                sda_z <= 1;
                shift_counter <= 0;
                latched_ack <= 1;
            end
            SendStart: begin
                latched_wvalid <= 0;
                sda_z <= 0;
                sda_out <= 0;
            end
            SendSlaveAddress: begin
                {sda_out, latched_slave_address[7:2]} <= latched_slave_address;
                if (shift_completed)
                    shift_counter <= 6;
                else
                    shift_counter <= shift_counter - 1;
            end
            SendRW: sda_out <= latched_rw;
            ReceiveSlaveAddressAck: begin
                sda_z <= 1;
            end
            SendDataAddress: begin
                sda_z <= 0;
                {sda_out, latched_data_address[7:1]} <= latched_data_address;
                if (shift_completed)
                    shift_counter <= 7;
                else
                    shift_counter <= shift_counter - 1;
            end
            ReceiveDataAddressAck: begin
                sda_z <= 1;
            end
            SendData: begin
                sda_z <= 0;
                {sda_out, latched_wdata[7:1]} <= latched_wdata;
                if (shift_completed)
                    shift_counter <= 7;
                else
                    shift_counter <= shift_counter - 1;
            end
            ReceiveDataAck: begin
                sda_z <= 1;
            end
            ReceiveData: begin
                sda_z <= 1;
                rdata <= {rdata[7:1], sda};
                shift_counter <= shift_counter - 1;
            end
            SendDataNack: begin
                sda_z <= 0;
                sda_out <= 1;
            end
            SendStop: begin
                sda_z <= 0;
                sda_out <= 0;
            end
        endcase
    end 
end

always @(posedge clk)
    if (scl_1) begin
        scl_high <= (state == Idle || state == SendStop);
        if (state == ReceiveSlaveAddressAck || state == ReceiveDataAddressAck || state == ReceiveDataAck)
            latched_ack <= sda;
        if (state == SendStop) begin
            sda_z <= 1;
        end
    end

endmodule
