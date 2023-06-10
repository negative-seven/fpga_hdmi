`timescale 1ns / 1ps

module test_i2c_master;

logic clk;
logic rst;

logic scl;
tri1 sda;

pullup(sda);

logic rw;
logic [7:0] data_address;
logic [7:0] wdata;
logic [7:0] rdata;
logic wvalid;
logic busy;

i2c_avd7511_master #(.clk_div(20)) i2c_master (
    .clk(clk),
    .rst(rst),
    .scl(scl),
    .sda(sda),
    .rw(rw),
    .data_address(data_address),
    .wdata(wdata),
    .wvalid(wvalid),
    .rdata(rdata),
    .rvalid(rvalid),
    .busy(busy)
);

logic [7:0] data_to_read;
i2c_slave i2c_slave(.scl(scl), .sda(sda), .dummy_data(data_to_read));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    wvalid = 0;
    repeat(2) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);
    
    write('b10100101, 'b10011001);
    repeat(50) @(posedge clk);    
    write('b00110011, 'b01100001);
    repeat(50) @(posedge clk);
    
    read('b00110011, 'b10011001);
    repeat(50) @(posedge clk);    
    read('b00110011, 'b01100001);
    repeat(50) @(posedge clk);
    $finish;
end

task write(input [7:0] address, input [7:0] data);
    rw = 0;
    data_address = address;
    wdata = data;
    wvalid = 1;
    @(posedge clk);
    wvalid = 0;
    
    @(negedge busy);
endtask

task read(input [7:0] address, input [7:0] data);
    
    data_to_read = data;

    rw = 1;
    data_address = address;
    wvalid = 1;
    @(posedge clk);
    wvalid = 0;
        
    @(negedge busy);
endtask

endmodule
