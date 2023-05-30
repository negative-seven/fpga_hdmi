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
    
    output hd_clk,
    output logic [7:0] hd_Y,
    output logic [7:0] hd_CbCr,
    output hd_de,
    output hd_hsync,
    output hd_vsync
);

assign hd_clk = clk;

typedef struct packed {
    enum logic [1:0] {Read, Write, Mask, Modify} operation;
    logic [7:0] data_address;
    union packed {
        logic [7:0] wdata;
        logic [7:0] mask;
    } content;
} transaction;

const transaction transactions [0:10 + 12] = '{
    '{Mask,   'h41, 1 << 6},
    '{Modify, 'h41, 0 << 6}, // set power-up
    '{Write,  'h98, 'h03}, // required write, per documentation
    '{Write,  'h9a, 'b11100000}, // required write, per documentation
    '{Write,  'h9C, 'h30}, // required write, per documentation
    '{Mask,   'h9D, 'b11},
    '{Modify, 'h9D, 'b01}, // required write, per documentation
    '{Write,  'hA2, 'hA4}, // required write, per documentation
    '{Write,  'hA3, 'hA4}, // required write, per documentation
    '{Write,  'hE0, 'hD0}, // required write, per documentation
    '{Write,  'hF9, 'h00}, // required write, per documentation

    // actual settings
    // 0x15[3:0] Input ID - 4:2:2 with separate syncs
    '{Mask,   'h15, 'b1111},
    '{Modify, 'h15, 'b0001},
    // 0x16[7] Output Format - 4:2:2
    // 0x16[5:4] Color Depth - 8 bit
    // 0x16[3:2] Input Style - style 2
    // 0x16[0] Output Colorspcace - YCbCr
    '{Mask,   'h16, 'b10111101},
    '{Modify, 'h16, 'b1 << 7 | 'b11 << 4 | 'b01 << 2 | 'b1},
    // 0x17[1] Input Aspect Ratio - 16:9
    '{Mask,   'h17, 1 << 1},
    '{Modify, 'h17, 1 << 1},
    // 0xAF[1] HDMI/DVI Mode - HDMI
    '{Mask,   'hAF, 1 << 1},
    '{Modify, 'hAF, 1 << 1},
    // 0xBA[7:5] Clock Delay - 1.6ns
    '{Mask,   'hBA, 'b111 << 5},
    '{Modify, 'hBA, 'b111 << 5},
    // 0x48[4:3] Video Input Justification - right justified
    '{Mask,   'h48, 'b11 << 3},
    '{Modify, 'h48, 'b01 << 3}
};

typedef enum { Idle, StartTransaction, WaitForEndTransaction, Stop } states;
states state;
states next_state;

logic [$clog2($size(transactions)) - 1:0] transaction_index;
logic rw;
logic [7:0] data_address;
logic [7:0] wdata;
logic wvalid;
logic [7:0] rdata;

logic [7:0] mask;

logic start_generator;
logic [11:0] x, y;

iic_avd7511_master #(clkdiv) master (
    .clk(clk), .rst(rst),
    .scl(hd_scl), .sda(hd_sda),
    .rw(rw), .data_address(data_address), .wdata(wdata), .wvalid(wvalid), .rdata(rdata), .rvalid(rvalid), .busy(busy)
);

sync_generator sync_generator(
    .clk(clk), .rst(rst), .start(start_generator),
    .x(x), .y(y), .de(hd_de), .hsync(hd_hsync), .vsync(hd_vsync)
);

localparam h = 480;
localparam w = 800;
always @(posedge clk) begin
    if ((x + y > 1 && x + y < 7 && x - y < 3 && y - x < 3) ||
        (x + y > (h + w - 2) - 7 && x + y < (h + w - 3) && x - y < (w - h) + 3 && y - x < (h - w) + 3))
        hd_Y <= 'hFF;
    else
        hd_Y <= 0;
    hd_CbCr <= 0;
end

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

transaction curr_trx = transactions[transaction_index];

always @(posedge clk, posedge rst) begin
    if (rst) begin
        transaction_index <= 0;
        state <= Idle;
        wvalid <= 0;
        start_generator <= 0;
    end
    else begin
        state <= next_state;
        case (state)
            StartTransaction: begin
                case (curr_trx.operation)
                    Read: begin
                        rw <= 1;               
                    end
                    Write: begin
                        rw <= 0;
                        wdata <= curr_trx.content.wdata;
                    end
                    Mask: begin
                        rw <= 1;
                        mask <= curr_trx.content.mask;
                    end
                    Modify: begin
                        rw <= 0;
                        wdata <= (~mask & rdata) | (mask & curr_trx.content.wdata);
                    end
                endcase
                data_address <= curr_trx.data_address;
                wvalid <= 1;
                transaction_index <= transaction_index + 1;
            end
            WaitForEndTransaction: begin
                wvalid <= 0;
            end
            Stop: begin
                start_generator <= 1;
            end
        endcase
    end
end

endmodule
