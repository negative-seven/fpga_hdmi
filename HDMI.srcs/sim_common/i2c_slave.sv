`timescale 1ns / 1ps

module i2c_slave (
    input scl,
    inout sda,
    input [7:0] dummy_data
);

logic sda_driven = 0;
assign sda = sda_driven ? 0 : 'z;

enum {Idle, ReceiveSlaveAddr, ReceiveRW, SendSlaveAddresAck, ReceiveData, SendDataAck, SendData, ReceiveDataAck} state;
integer counter = 0;
logic rw;

initial begin
    forever @(negedge sda)
        if (scl) begin
            state = ReceiveSlaveAddr;
            counter = 0; 
        end
end

initial begin
    forever @(posedge sda)
        if (scl)
            state = Idle;
end

initial begin
    forever @(posedge scl) begin
        case (state)
            ReceiveSlaveAddr:
                if (counter == 7)
                    state = ReceiveRW;
            ReceiveRW: begin
                rw = sda;
                state = SendSlaveAddresAck;
            end
            SendSlaveAddresAck: begin
                sda_driven = 1;
                state = rw ? SendData : ReceiveData;
                counter = 0;
            end
            ReceiveData:
                if (counter == 8)
                    state = SendDataAck;
        endcase
    end
end

initial begin
    forever @(negedge scl) begin
        counter++;
        sda_driven <= 0;
    end
end
    
endmodule