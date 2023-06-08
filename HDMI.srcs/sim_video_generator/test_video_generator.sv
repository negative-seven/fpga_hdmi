`timescale 1ns / 1ps

module test_video_generator;

logic clk, rst;

logic start_generator;
logic [15:0] hd_data;

video_generator video_generator(
    .clk(clk), .rst(rst), .start(start_generator),
    .data_clk(hd_clk), .data(hd_data), .de(hd_de), .hsync(hd_hsync), .vsync(hd_vsync)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

localparam image_divider = 4;
int x_counter;
int y_counter;

initial begin
    rst = 1;
    start_generator = 0;

    repeat(2) @(posedge clk);
    rst = 0;
    #5 start_generator = 1;
end

endmodule
