`include "opcodes.v"

module control #(
   parameter DATA_W = 14, 
   parameter ADDR_W = 12
) (
    input clk, reset,
    input [DATA_W - 1:0] data_in, 
    input [DATA_W - 1:0] data_GPRin,
    input [DATA_W - 1:0] data_ALUresult,

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

    /*output and input on GPR bus*/
    output reg [DATA_W - 1:0] data_GPRout,
    output reg [ADDR_W - 1:0] addr_GPR
); 
    reg [DATA_W - 1:0] command [0:1];
    reg [ADDR_W - 1:0] IP;
    reg [8:0] FLAG; 
    reg [3:0] latency_counter; 
    reg [7:0] state; 
    reg [3:0] OP; 
    reg [ADDR_W - 1:0] address; 

    localparam READ_ROM_LAT = 3;

    localparam HLT = 0;
    localparam READ_ROM = 1, DECODE = 2;
    localparam WRITE = 3;
    initial begin
        state <= 0; 
        IP <= 0; 
    end

    always @(posedge clk ) begin
			
            case (OP)
            `OP_JMP: begin
                IP <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
            end
            `OP_JNZ: begin
                if(FLAG[0] == 1'b1) begin
                    IP <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                end
            end

        endcase
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
                    rom_rd <= 1'b0;

                    ram_rd <= 1'b0;
                    ram_wr <= 1'b0;

                    GPR_rd <= 1'b0;
                    GPR_wr <= 1'b0;        
                end
                READ_ROM: begin
                    if (latency_counter == 0) begin
                        state <= DECODE;
                        rom_rd <= 1'b0;
                    end else begin
                        rom_rd <= 1'b1;
                        addr_out <= IP;
                        command[READ_ROM_LAT - latency_counter-1] <= data_in;
                        if (latency_counter - 1 != 0) begin
                            IP <= IP + 1;
                        end  
                    end
                end
                DECODE: begin
                    OP <= command[0][DATA_W - 1: DATA_W - 4]; 
                    opcode <= OP;
                    state <= WRITE;
                    case (OP)
                        `OP_MOV_SR,`OP_INC_SR: begin
                            GPR_rd <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8'b00000000};
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
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8'b0};
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
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8'b0};
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
                    state <= HLT; 
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
                        `OP_MOV_SA: begin
                            ram_rd <= 1'b1;
                            GPR_wr <= 1'b1;
                            addr_out <= {command[0][DATA_W - 9:0], command[1][DATA_W - 1: DATA_W - 6]};
                            data_GPRout = data_in; 
                        end 
                        `OP_XOR_SR, `OP_SRA_SR, `OP_NAND_SR: begin
                            GPR_wr <= 1'b1;
                            addr_GPR <= {command[0][DATA_W - 5: DATA_W - 9], 8'b0};
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