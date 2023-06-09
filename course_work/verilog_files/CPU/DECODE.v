`include "opcodes.v"
module DECODE #(
    parameter DATA_W = 14, 
    parameter ADDR_W = 12
) (
    input clk, reset,
    input [DATA_W*2 - 1:0] command_in,
    input pause_DECODE,
    output reg comm_read,

    input ram_garant_rd,
    output reg ram_rd,
    output reg [ADDR_W - 1:0] addr_out,
    input [DATA_W - 1:0] data_in, 
 
    output reg [3:0] opcode,

    output reg GPR_rd,
    input [DATA_W - 1:0] data_GPRin,
    output reg [ADDR_W - 1:0] addr_GPRin,

    input [DATA_W-1:0] data_ALUresult,
    output reg [DATA_W - 1:0] data_ALU0, data_ALU1,


    output reg [DATA_W+ADDR_W + 4 - 1 : 0] complex_data,
    output reg data_write,

    input [DATA_W-1:0] data_stack_pop,
	output reg [DATA_W-1:0] data_stack_push
);
    reg [DATA_W-1:0] commands[0:1];
    localparam READ_COMM_LAT = 1, WRITE_COMM_LAT = 1;
    localparam DECODE_LAT = 1, INIT_LAT = 2, EXEC_LAT = 5;
    localparam  INIT=0, READ_COMM=1, DECODE = 3, WRITE_COMM=2, EXEC = 4, WRITE_DATA=5, HLT = 6;

    reg [3:0] state;
    reg [3:0] latency_counter;
    reg [3:0] stage;
    reg wait_sig; 
    // reg data_write;

    /*4 is len of opcode*/
    // reg [DATA_W+ADDR_W + 4 - 1 : 0] complex_data;
    reg [DATA_W-1:0] data;
    reg [ADDR_W-1:0] address;

    reg [1:0] alu_state;


    always @(posedge clk) begin
        if(reset) begin
            comm_read <= 0;
            state <= INIT; 
            latency_counter <= INIT_LAT;
            wait_sig <= 0;
            ram_rd <= 0;
            addr_out <= 12'bzzzzzzzzzzzz;
            GPR_rd <= 0;
            alu_state <= 0;
        end else if(pause_DECODE == 0) begin
            if(latency_counter != 0 && wait_sig == 0) begin
                latency_counter <= latency_counter-1;
                if(alu_state != 0) begin
                    alu_state <= alu_state - 1;
                end
            end
            case(state)
                INIT: begin
                    if(latency_counter == 0) begin
                        state <= READ_COMM;
                    end
                    data_write <= 1'b0;

                end
                READ_COMM: begin
                    state <= WRITE_COMM;
                    latency_counter <=WRITE_COMM_LAT;
                    comm_read <= 1'b1;
                end
                WRITE_COMM: begin
                    state <= DECODE;
                    //latency_counter <=DECODE_LAT;
                    commands[0] <= command_in[DATA_W-1:0];
                    commands[1] <= command_in[DATA_W*2-1:DATA_W];    
                    comm_read <= 1'b0;
                end
                DECODE: begin
                    state <= EXEC;
                    latency_counter <= EXEC_LAT;
                    opcode <= commands[0][DATA_W-1:DATA_W-4];
                    alu_state <= 2'b11;
                end
                EXEC: begin
                    if(latency_counter == 0) begin
                        state <= WRITE_DATA;
                        GPR_rd <= 1'b0;
                        ram_rd <= 1'b0;
                        addr_out <= 12'bzzzzzzzzzzzz;
                        addr_GPRin <= 12'bzzzzzzzzzzzz;
                        alu_state <= 0;
                    end else begin
                        case(opcode)
                            `OP_MOV_SR: begin
                                address <= {commands[0][DATA_W - 9:0], commands[1][DATA_W - 1: DATA_W - 6]};
                                data <= data_GPRin; 
                                addr_GPRin <= {commands[0][DATA_W - 5: DATA_W - 8], 8'b00000000};
                                GPR_rd <= 1'b1;
                            end
                            `OP_MOV_SA: begin
                                ram_rd <= 1'b1;
                                if(ram_garant_rd == 1) begin
                                    addr_out <= {commands[0][DATA_W - 9:0], commands[1][DATA_W - 1: DATA_W - 6]};
                                    data <= data_in;
                                    address <= {commands[0][DATA_W - 5: DATA_W - 8], 8'd0};
                                    wait_sig <= 0;
                                end else begin 
                                    wait_sig <= 1; 
                                end
                            end
                            `OP_MOV_BIO: begin 
                                GPR_rd <= 1'b1;
                                ram_rd <= 1'b1;
                                addr_GPRin <= {commands[0][DATA_W - 5:0], commands[1][DATA_W - 1:DATA_W - 2]};
                                if(ram_garant_rd == 1) begin
                                    addr_out <= data_GPRin;
                                    data <= data_in;
                                    address <= {commands[1][DATA_W - 3 : 0]}; 
                                    wait_sig <= 0;
                                end else begin 
                                    wait_sig <= 1; 
                                end
                            end 
                            `OP_INC_SR: begin
                                GPR_rd <= 1'b1;
                                addr_GPRin <= {commands[0][DATA_W - 5: DATA_W - 8], 8'b00000000};
                                data_ALU0 <= data_GPRin;

                                data <= data_ALUresult;
                                address <= {commands[0][DATA_W - 5: DATA_W - 8], 8'b00000000};
                            end
                            `OP_INC_BIO: begin
                                GPR_rd <= 1'b1;
                                ram_rd <= 1'b1;
                                addr_GPRin <= {commands[0][DATA_W - 5:0], commands[1][DATA_W - 1:DATA_W - 2]};
                                if(ram_garant_rd == 1) begin
                                    addr_out <= data_GPRin;
                                    address <= {addr_out};
                                    data_ALU0 <= data_in;
                                    data <= data_ALUresult;
                                    wait_sig <= 0;
                                end else begin 
                                    wait_sig <= 1; 
                                end
                            end
                            `OP_XOR_SR,
                            `OP_NAND_SR,
                            `OP_SRA_SR:begin
                                GPR_rd <= 1'b1;
                                addr_GPRin <= {commands[0][DATA_W - 5: DATA_W - 8], 8'b00000000};
                                data_ALU0 <= data_GPRin;
                                ram_rd <= 1'b1;
                                if(ram_garant_rd == 1) begin
                                    addr_out <= {commands[0][DATA_W - 9:0], commands[1][DATA_W - 1: DATA_W - 6]};
                                    data_ALU1 <= data_in;
                                    address <= {addr_out}; 
                                    wait_sig <= 0;
                                end else begin
                                    wait_sig <= 1; 
                                end
                                data <= data_ALUresult;
                            end
                            `OP_XOR_BIO,
                            `OP_NAND_BIO,
                            `OP_SRA_BIO:begin
                                GPR_rd <= 1'b1;
                                ram_rd <= 1'b1;
                                addr_GPRin <= {commands[0][DATA_W - 5:0], commands[1][DATA_W - 1:DATA_W - 2]};
                                if(ram_garant_rd == 1) begin
                                    wait_sig <= 0;
                                    if (alu_state > 1) begin
                                        addr_out <= data_GPRin;
                                        address <= addr_out;
                                        data_ALU0 <= data_in;    
                                    end else begin
                                        addr_out <= {commands[1][DATA_W - 3 : 0]};
                                        data_ALU1 <= data_in;
                                    end
                                end else begin 
                                    wait_sig <= 1;
                                end
                                data <= data_ALUresult;
                            end
                            `OP_PUSH_R: begin
                                GPR_rd <= 1'b1;
                                addr_GPRin <= {commands[0][DATA_W - 5:0], commands[1][DATA_W - 1:DATA_W - 2]};
                                data_stack_push <= data_GPRin;
                            end
                            `OP_POP_R: begin
                                data <= data_stack_pop;
                                address <= {commands[0][DATA_W - 5:0], commands[1][DATA_W - 1:DATA_W - 2]};
                            end
                            `OP_HLT: begin
                                state <= HLT;
                            end
                        endcase
                    end
                end
                WRITE_DATA: begin
                    complex_data <= {data, address, opcode};
                    data_write <= 1'b1;
                    state <= INIT;
                    latency_counter <= INIT_LAT;
                end
                HLT: begin
                    state <= HLT;
                end
            endcase
        end
    end
endmodule