`timescale 1ns / 1ps

module test_top;

logic clk;
logic rst;

wire hd_scl;
tri1 hd_sda;

pullup(hd_sda);

wire hd_clk;
wire hd_de;
wire hd_hsync;
wire hd_vsync;
wire [15:0] hd_data;

top #(.clkdiv(10), .ms_wait_adv(1)) top_instance (
    .clk(clk), .rst(rst),
    .hd_scl(hd_scl), .hd_sda(hd_sda),
    .hd_clk(hd_clk), .hd_data(hd_data), .hd_de(hd_de), .hd_hsync(hd_hsync), .hd_vsync(hd_vsync));

const logic [7:0] dummy_data_to_read = 'b01101001;
i2c_slave i2c_slave(.scl(hd_scl), .sda(hd_sda), .dummy_data(dummy_data_to_read));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;
    
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_write();
    // respond_to_read();
end

endmodule
