`timescale 1ps/1ps
`include "../memory/rom.v"
`include "../memory/ram.v"
`include "ALU.v"
`include "GPR.v"
`include "stack.v"

module controltb; 
    localparam DATA_W = 14;
    localparam ADDR_W = 12;
    reg clk, reset;
    wire [DATA_W - 1:0] data_in;
    reg [DATA_W - 1:0] data_ALUresult;
    reg [DATA_W - 1:0] data_GPRin;

    /*output on general bus*/
    wire [DATA_W - 1:0] data_out;
    wire [ADDR_W - 1:0] addr_out;
    /* control bus*/
    wire [3:0] opcode;
    
    wire rom_rd;
    wire ram_rd;
    wire ram_wr;
    
    wire GPR_rd;
    wire GPR_wr;
    /*output on ALU bus*/
    wire [DATA_W - 1:0] data_ALU0;
    wire [DATA_W - 1:0] data_ALU1;

    /*output and input on GPR bus*/
    wire [DATA_W - 1:0] data_GPRout;
    wire [ADDR_W - 1:0] addr_GPR;

    control control(.clk(clk), 
                .reset(reset),
                .data_in(data_in), 
                .data_out(data_out), 
                .addr_out(addr_out), 
                .opcode(opcode),
                .rom_rd(rom_rd),
                .ram_rd(ram_rd), 
                .ram_wr(ram_wr),
                .GPR_rd(GPR_rd), 
                .GPR_wr(GPR_wr), 
                .data_ALU0(data_ALU0), 
                .data_ALU1(data_ALU1), 
                .data_ALUresult(data_ALUresult),
                .data_GPRin(data_GPRin),
                .data_GPRout(data_GPRout),
                .addr_GPR(addr_GPR)); 
    
    rom ROM(.address(addr_out),
            .clk(clk), 
            .rden(rom_rd),
            .data(data_in)); 

    initial begin
        clk <= 0;
		reset <= 0;
        //data_in <= 14'd0;
        data_ALUresult <= 14'd0;
        data_GPRin <= 14'd0;
	end

    initial begin
        #5 reset <= 1'b1; 
        #5 reset <= 1'b0; 
        //#5  data_in <= 14'b0001_0000_000000;
        //#10 data_in <= 14'b000111_00000000;
    end

    initial begin
        #1000 $stop;
    end
    always begin
        #5
        clk = ~clk; 
    end

endmodule