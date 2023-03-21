`include "opcades.v"

module control #(
   parameter DATA_W = 14, 
   parameter ADDR_W = 12, 
) (
    input clk, reset
    
    input [DATA_W - 1:0] data_in, 
    input [ADDR_W - 1:0] addr_in,

    /*output on general bus*/
    output reg [DATA_W - 1:0] data_out, 
    output reg [ADDR_W - 1:0] addr_out,
    
    /* control bus*/
    output reg [3:0] opcode, 
    
    output reg rom_rd,

    output reg ram_rd,
    output reg ram_wr,
    
    output reg GPR_rd,
    output reg GPR_wr,

    /*output on ALU bus*/
    output reg [DATA_W - 1:0] data_ALU0,
    output reg [DATA_W - 1:0] data_ALU1,
    input [DATA_W - 1:0] data_ALUresult,

    /*output and input on GPR bus*/
    input [DATA_W - 1:0] data_GPRin;
    output reg [DATA_W - 1:0] data_GPRout,
    output reg [ADDR_W - 1:0] addr_GPR

); 
    reg [DATA_W - 1:0] command [0:2];
    reg [ADDR_W - 1:0] IP;
    reg [8:0] FLAG; 
    reg [3:0] latency_counter; 
    reg [7:0] state; 
    reg [3:0] OP; 
    reg [ADDR_W - 1:0] address; 

    parameter READ_ROM_LAT = 3;

    localparam HLT = 0;
    localparam READ_ROM = 1, DECODE = 2;
    localparam READ_REG = 3, READ_ADDR = 4, READ_BIO = 5;
    localparam WRITE = 6, WRITE_REG = 7, WRITE_ADDR = 8;

    always @(posedge clk ) begin
        if (reset) begin
            latency_counter <= 0;
            IP <= 0;
            rom_rd <= 1'b0;
            ram_rd <= 1'b0;
            ram_wr <= 1'b0;
            GPR_rd <= 1'b0;
            GPR_wr <= 1'b0;
            state <= HLT;
            OP <= 1'b0; 
            FLAG <= 0; 
        end else begin
            if(latency_counter != 0) begin
                latency_counter <= latency_counter - 1;
            end
            case (state)
                HLT: begin
                    latency_counter <= READ_ROM_LAT; 
                    state <= READ_ROM;  
                    opcode <= `OP_HLT;
                end
                READ_ROM: begin
                    if (latency_counter == 0) begin
                        state <= DECODE_AND_READ;
                        ram_rd <= 1'b0;
                    end else begin
                        ram_rd <= 1'b1;
                        addr_out <= IP;
                        command[(READ_ROM_LAT-1)-latency_counter] <= data_in; 
                        IP <= IP + 1;
                    end
                end
                DECODE: begin
                    OP <= command[0][DATA_W - 1: DATA_W - 4]; 
                    opcode <= OP;
                    state <= WRITE;
                    case (OP)
                        `OP_MOV_SR,`OP_INC_SR: begin
                            GPR_rd <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8(1'b0)};
                        end 
                        `OP_MOV_SA: begin
                            ram_rd <= 1'b1; 
                            addr_out <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                        end
                        `OP_INC_BIO, `OP_MOV_BIO: begin
                            GPR_rd <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5:0], command[1][DATA_W - 1:DATA_W - 2]};
                        end
                        `OP_XOR_SR, `OP_SRA_SR, `OP_NAND_SR: begin
                            GPR_rd <= 1'b1;
                            ram_rd <= 1'b1; 
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8(1'b0)};
                            addr_out <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                            data_ALU0 <= data_in; 
                            data_ALU1 <= data_GPRin; 
                        end
                        `OP_XOR_BIO, `OP_SRA_BIO, `OP_NAND_BIO: begin
                            GPR_rd <= 1'b1;
                            ram_rd <= 1'b1; 
                            addr_GPR <= {command[0][DATA_W - 5:0], command[1][DATA_W - 1:DATA_W - 2]};
                            addr_out <= {command[1][DATA_W - 3 : 0]};
                            data_ALU0 <= data_in; 
                            data_ALU1 <= data_GPRin; 
                        end
                        `OP_PUSH_R: begin
                            GPR_rd <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8(1'b0)};
                            data_out <= data_GPRin;
                        end
                        `OP_JNZ: begin
                            if(FLAG[0] == 1'b1) 
                                IP <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                        end 
                        `OP_JMP: begin
                            IP <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                        end
                    endcase
                end
                WRITE: begin
                    GPR_rd <= 1'b0;
                    ram_rd <= 1'b0; 
                    case (OP)
                        `OP_MOV_BIO: begin
                            GPR_rd <= 1'b1;
                            ram_wr  <= 1'b1;
                            addr_out <= {command[1][DATA_W - 3 : 0]};
                            data_out <= data_GPRin;
                        end
                        `OP_MOV_SR: begin
                            GPR_rd <= 1'b1;
                            ram_wr  <= 1'b1;
                            addr_out <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                            data_out <= data_GPRin;
                        end
                        `OP_MOV_SR, `OP_XOR_SR, `OP_SRA_SR, `OP_NAND_SR: begin
                            GPR_wr <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8(1'b0)};
                            data_GPRout <= data_ALUresult; 
                        end
                        `OP_XOR_BIO, `OP_SRA_BIO, `OP_NAND_BIO: begin
                            GPR_rd <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5:0], command[1][DATA_W - 1:DATA_W - 2]};
                            addr_out <= data_GPRin[ADDR_W-1:0]; 
                            data_out <= data_ALUresult; 
                        end
                    endcase
                end
            endcase
        end
    end
endmodule