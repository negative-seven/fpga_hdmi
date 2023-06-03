`timescale 1ns / 1ps

module color_selector #(parameter
    image_width = 800,
    image_height = 480
) (
    input clk,
    input [11:0] x,
    input [11:0] y,
    output logic [7:0] Y,
    output logic [7:0] Cb,
    output logic [7:0] Cr
);

localparam image_size = image_width * image_height / 16;

(* rom_style="block" *)
logic [23:0] image [0:image_size-1];
logic [$clog2(image_size)-1:0] position;

initial $readmemh("watermelon.mem", image);

assign Y = image[position][23:16];
assign Cb = image[position][15:8];
assign Cr = image[position][7:0];

// TODO this is now unsynchronized with syncs, to be fixed
always @(posedge clk) begin
    position <= x[11:2] + image_width / 4 * y[11:2];
end


endmodule
