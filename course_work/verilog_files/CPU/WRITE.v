`include "opcodes.v"
module WRITE #(
    parameter DATA_W = 14,
    parameter ADDR_W = 12
) (
    input clk, reset,
    
    input pause_WRITE,
    input [DATA_W+ADDR_W+3:0]DAO,
    output reg data_read,

    output reg GPR_wr, 
    output reg [DATA_W-1:0] data_GPRout,
    output reg [ADDR_W-1:0] addr_GPRout,

    output reg ram_wr,
    input ram_garant_wr,
    output reg [DATA_W-1:0] data_out,
    output reg [ADDR_W-1:0] addr_out
);
    
localparam INIT = 0, READ_DATA = 1, DECODE = 2, WR_MEM = 3;
localparam INIT_LAT = 1, READ_DATA_LAT = 1, WR_MEM_LAT = 1;

reg [1:0] state;
reg [3:0] latency_counter; 
reg [DATA_W-1:0] data;
reg [ADDR_W-1:0] addr; 
reg [3:0] opcode;
reg wait_sig;

always @(posedge clk) begin
    if(reset) begin
        state <= INIT; 
        GPR_wr <= 1'b0;
        ram_wr <= 1'b0;
        wait_sig <= 0; 
        data <= 0; 
        addr <= 0; 
        opcode <= 0;
        addr_out <= 12'bzzzzzzzzzzzz;  
        addr_GPRout <= 12'bzzzzzzzzzzzz;
		latency_counter <= 0;
    end else begin
        if(latency_counter != 0 && wait_sig == 0) begin
            latency_counter <= latency_counter-1; 
        end
        case(state)
            INIT: begin
                GPR_wr <= 1'b0;
                ram_wr <= 1'b0;
				state <= READ_DATA;
                addr_out <= 12'bzzzzzzzzzzzz;  
                addr_GPRout <= 12'bzzzzzzzzzzzz; 
            end
            READ_DATA: begin
                data_read <= 1'b1;
                if(pause_WRITE == 0) begin
                    state <= DECODE;
                end else begin
                    data_read <= 0; 
                    state <= READ_DATA;
                end
            end
            DECODE: begin
                data <= DAO[DATA_W+ADDR_W+3:ADDR_W+4];
                addr <= DAO[ADDR_W+3:4]; 
                opcode <= DAO[3:0]; 
                data_read <= 1'b0;
                state <= WR_MEM;
            end
            WR_MEM: begin
                case (opcode)
                    `OP_MOV_SR, 
                    `OP_MOV_BIO, 
                    `OP_INC_BIO, 
                    `OP_XOR_SR,
                    `OP_XOR_BIO,
                    `OP_NAND_BIO,
                    `OP_NAND_SR,
                    `OP_SRA_BIO,
                    `OP_SRA_SR: begin
                        ram_wr <= 1'b1;
                        if(ram_garant_wr == 1) begin
                            wait_sig <= 0;
                            addr_out <= addr;
                            data_out <= data;
							state <= INIT; 
                        end else begin
                            wait_sig <= 1;
                        end
                    end
                    `OP_MOV_SA, 
                    `OP_INC_SR,
                    `OP_POP_R: begin 
                        GPR_wr <= 1'b1; 
                        data_GPRout <= data;
                        addr_GPRout <= addr;
                        state <= INIT;
                    end
                    default: begin
                        state <= INIT; 
                    end
                endcase
            end
        endcase
    end
end


endmodule