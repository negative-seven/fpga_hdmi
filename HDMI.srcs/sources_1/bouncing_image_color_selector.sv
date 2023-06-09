`timescale 1ns / 1ps

module bouncing_image_color_selector #(parameter
    screen_width = 0,
    screen_height = 0,
    image_width = 0,
    image_height = 0
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

logic [11:0] image_x, x2;
logic [11:0] image_y, y2;
logic moving_right;
logic moving_down;

(* rom_style="block" *)
logic [23:0] image [0:image_size-1];
logic [$clog2(image_size)-1:0] position;

initial $readmemh("watermelon.mem", image);

logic [$clog2(image_size) - 1:0] mul_by_image_width_table [0:image_height - 1];
genvar i;
generate
    for (i = 0; i < image_height; i++)
        assign mul_by_image_width_table[i] = i * image_width;
endgenerate
  
always @(posedge clk) begin
    if (rst) begin
        image_x <= 0;
        image_y <= 0;
        moving_right <= 1;
        moving_down <= 1;
    end
    else begin
        if (x == screen_width - 1 && y == screen_height - 1) begin // update image position and velocity after final pixel
            image_x <= image_x + (moving_right ? 1 : -1);
            image_y <= image_y + (moving_down ? 1 : -1);
            
            if (moving_right && image_x >= screen_width - image_width - 1)
                moving_right <= 0;
            else if (!moving_right && image_x <= 1)
                moving_right <= 1;
                
            if (moving_down && image_y >= screen_height - image_height - 1)
                moving_down <= 0;
            else if (!moving_down && image_y <= 1)
                moving_down <= 1;
        end
   end
end

always @(posedge clk) begin    
    // using direct multiplication is too slow for timing constraints; use lookup table instead
    position <= mul_by_image_width_table[y - image_y] + (x - image_x);
end

always @* begin
    if (x >= image_x && x < image_x + image_width && y >= image_y && y < image_y + image_height) begin
        Y = image[position][23:16];
        Cb = image[position][15:8];
        Cr = image[position][7:0];
    end
    else begin
        Y = 64;
        Cb = 192;
        Cr = 64;
    end
end

endmodule
