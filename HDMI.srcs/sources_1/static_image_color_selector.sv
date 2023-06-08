`timescale 1ns / 1ps

module static_image_color_selector #(parameter
    image_width = 200,
    image_height = 120,
    scale_factor = 4
) (
    input clk,
    input rst,
    input [11:0] x,
    input [11:0] y,
    output logic [7:0] Y,
    output logic [7:0] Cb,
    output logic [7:0] Cr
);

localparam image_size = image_width * image_height;

(* rom_style="block" *)
logic [23:0] image [0:image_size-1];
logic [$clog2(image_size)-1:0] position;

initial $readmemh("watermelon.mem", image);

assign Y = image[position][23:16];
assign Cb = image[position][15:8];
assign Cr = image[position][7:0];

always @(posedge clk) begin
    position <= (x / scale_factor) + image_width * (y / scale_factor);
end


endmodule
