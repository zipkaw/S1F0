module commands_ram #(
    parameter DATA_W = 14 + 12 + 4, 
    parameter REGS = 16
) (
    input clk, reset,
    input [DATA_W-1:0] data_in,
    input comm_write,
    input comm_read,

    output reg [DATA_W-1:0] data_out,
    output reg pause_DECODE,
    output reg pause_WRITE
);
    /*
        DAO(data addr opcode) :
        data format {14 bits of data, 12'b of addr, 4'b of ocode },{0/1 byte of sign}
        the sign 1 means that data needed send to DECODE 
        0 means that data needed repair new one.
    */
    reg [DATA_W:0] DAO [0:REGS-1]; 
    reg [3:0] to_write_command;
    reg [3:0] to_read_command; 

    `define data_len 30
    `define x30 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	integer i;
    initial begin
		pause_WRITE <= 1;
		pause_DECODE <= 0;
        for(i = 0; i<REGS; i = i + 1) begin
            DAO[i] = {30'b`x30, 1'b0};
        end
    end
    
 
    always @(negedge comm_write) begin
        if ({DAO[0][0], DAO[0][0]}== 2'b11) begin
            pause_WRITE <= 0;
        end 
    end
    /* {data:0/1} 
        1: means data writed;
        0: means data readed(or hasn't been writed yet);
    */
    always @(negedge clk) begin
        if(reset) begin
            to_write_command <= 4'd0;
            to_read_command <= 4'd0;
        end else begin
            if(comm_write) begin
                if(DAO[to_write_command][0] == 1'b0) begin
                    pause_DECODE <= 1'b0;
                    DAO[to_write_command] <= {data_in, 1'b1};
                    to_write_command <= 1 + to_write_command;
                end else begin
                    pause_DECODE <= 1'b1;
                end
            end
            if(comm_read == 1'b1) begin
                if(DAO[to_read_command][0] == 1'b1)begin
                    data_out <= {DAO[to_read_command][DATA_W-1:0]}; 
                    DAO[to_read_command]   <= {30'b`x30, 1'b0};
                    to_read_command <= 2 + to_read_command; 
                end
            end
        end
    end
endmodule