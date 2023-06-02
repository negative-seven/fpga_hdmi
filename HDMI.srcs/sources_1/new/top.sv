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

typedef enum logic [0:0] {InterfaceModeDVI = 0, InterfaceModeHDMI = 1} interface_mode;
const interface_mode INTERFACE_MODE = InterfaceModeHDMI;

// Input IDs:
// 0000 = 24 bit RGB 4:4:4 or YCbCr 4:4:4 (separate syncs)
// 0001 = 16, 20, 24 bit YCbCr 4:2:2 (separate syncs)
// 0010 = 16, 20, 24 bit YCbCr 4:2:2 (embedded syncs)
// 0011 = 8, 10, 12 bit YCbCr 4:2:2 (2x pixel clock, separate syncs)
// 0100 = 8, 10, 12 bit YCbCr 4:2:2 (2x pixel clock, embedded syncs)
// 0101 = 12, 15, 16 bit RGB 4:4:4 or YCbCr (DDR with separate syncs)
// 0110 = 8, 10, 12 bit YCbCr 4:2:2 (DDR with separate syncs)
// 0111 = 8, 10, 12 bit YCbCr 4:2:2 (DDR separate syncs)
// 1000 = 8, 10, 12 bit YCbCr 4:2:2 (DDR embedded syncs)
const logic [3:0] INPUT_ID = 'b0001;

typedef enum logic [1:0] {InputStyle2 = 'b01, InputStyle1 = 'b10, InputStyle3 = 'b11} input_style;
const input_style INPUT_STYLE = InputStyle3;

typedef enum logic [1:0] {InputVideoEvenlyDistributed = 'b00, InputVideoRightJustified = 'b01, InputVideoLeftJustified = 'b10} input_video_justification;
const input_video_justification INPUT_VIDEO_JUSTIFICATION = InputVideoEvenlyDistributed;

typedef enum logic [1:0] {InputColorDepth12Bit = 'b10, InputColorDepth10Bit = 'b01, InputColorDepth8Bit = 'b11} input_color_depth;
const input_color_depth INPUT_COLOR_DEPTH = InputColorDepth8Bit;

typedef enum logic [0:0] {InputAspectRatio4_3 = 0, InputAspectRatio16_9 = 1} input_aspect_ratio;
const input_aspect_ratio INPUT_ASPECT_RATIO = InputAspectRatio4_3;

const enum logic [0:0] {InterpolationStyleZeroOrder = 0, InterpolationStyleFirstOrder = 1}
    INTERPOLATION_STYLE = InterpolationStyleFirstOrder;

typedef enum logic [2:0] {
    InputVideoClockDelayNegative1200ns = 'b000,
    InputVideoClockDelayNegative800ns = 'b001,
    InputVideoClockDelayNegative400ns = 'b010,
    InputVideoClockDelayNone = 'b011,
    InputVideoClockDelay400ns = 'b100,
    InputVideoClockDelay800ns = 'b101,
    InputVideoClockDelay1200ns = 'b110,
    InputVideoClockDelay1600ns = 'b111
} input_video_clock_delay;
const input_video_clock_delay INPUT_VIDEO_CLOCK_DELAY = InputVideoClockDelay1600ns;

typedef enum logic [0:0] {OutputFormat4_4_4 = 0, OutputFormat4_2_2 = 1} output_format;
const output_format OUTPUT_FORMAT = OutputFormat4_2_2;

typedef enum logic [0:0] {OutputColorSpaceRGB = 0, OutputColorSpaceYCbCr = 1} output_color_space;
const output_color_space OUTPUT_COLOR_SPACE = OutputColorSpaceRGB;

const logic COLOR_SPACE_CONVERTER_ENABLED = 1;

typedef struct packed {
    enum logic [1:0] {Read, Write, Mask, Modify} operation;
    logic [7:0] data_address;
    union packed {
        logic [7:0] wdata;
        logic [7:0] mask;
    } content;
} transaction;

logic a = InterfaceModeDVI;

const transaction transactions [0:10 + 14] = '{
    // initialization
    '{Mask,   'h41, 1 << 6},
    '{Modify, 'h41, 0 << 6}, // set power-up
    '{Write,  'h98, 'h03}, // required write, per documentation
    '{Write,  'h9A, 'b11100000}, // required write, per documentation
    '{Write,  'h9C, 'h30}, // required write, per documentation
    '{Mask,   'h9D, 'b11},
    '{Modify, 'h9D, 'b01}, // required write, per documentation
    '{Write,  'hA2, 'hA4}, // required write, per documentation
    '{Write,  'hA3, 'hA4}, // required write, per documentation
    '{Write,  'hE0, 'hD0}, // required write, per documentation
    '{Write,  'hF9, 'h00}, // required write, per documentation

    // video settings
    // 0x15[3:0] Input ID
    '{Mask,   'h15, 'b1111},
    '{Modify, 'h15, INPUT_ID},
    // 0x16[7] Output Format
    // 0x16[5:4] Color Depth
    // 0x16[3:2] Input Style
    // 0x16[0] Output Color Space
    '{Mask,   'h16, 'b10111101},
    '{Modify, 'h16, OUTPUT_FORMAT << 7 | INPUT_COLOR_DEPTH << 4 | INPUT_STYLE << 2 | OUTPUT_COLOR_SPACE},
    // 0x17[2] 4:2:2 to 4:4:4 Interpolation Style
    // 0x17[1] Input Aspect Ratio
    '{Mask,   'h17, 1 << 2 | 1 << 1},
    '{Modify, 'h17, INTERPOLATION_STYLE << 2 | INPUT_ASPECT_RATIO << 1},
    // 0xAF[1] HDMI/DVI Mode
    '{Mask,   'hAF, 1 << 1},
    '{Modify, 'hAF, INTERFACE_MODE << 1},
    // 0xBA[7:5] Clock Delay
    '{Mask,   'hBA, 'b111 << 5},
    '{Modify, 'hBA, INPUT_VIDEO_CLOCK_DELAY << 5},
    // 0x48[4:3] Video Input Justification
    '{Mask,   'h48, 'b11 << 3},
    '{Modify, 'h48, INPUT_VIDEO_JUSTIFICATION << 3},
    // 0x18[7] Color Space Converter Enable
    '{Mask,   'h18, 1 << 7},
    '{Modify, 'h18, COLOR_SPACE_CONVERTER_ENABLED << 7}
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

assign hd_clk = clk;

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

localparam imageSize = w * h / 16;
(* rom_style="block" *)
logic [23:0] image [0:imageSize-1];
initial $readmemh("watermelon.mem", image);

logic [$clog2(w*h)-1:0] position;

logic [7:0] Y;
logic [7:0] Cb;
logic [7:0] Cr;

// TODO this is now unsynchronized with syncs, to be fixed
always @(posedge clk) begin
    position <= x[11:2] + w / 4 * y[11:2];

    Y <= image[position][23:16];
    Cb <= image[position][15:8];
    Cr <= image[position][7:0];
end

wire oddPixel = x[0];

always @(posedge clk) begin
    hd_Y <= Y;
    hd_CbCr <= !oddPixel ? Cb : Cr;
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
