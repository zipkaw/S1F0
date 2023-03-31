`include "opcodes.v"

module cpu #(
    parameter DATA_W = 14, ADDR_W = 12
) (
    input clk,
    input reset
);

    wire [DATA_W - 1:0] data_in;
		
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
    wire [DATA_W - 1:0] data_ALUresult;

    /*output and input on GPR bus*/
    wire [DATA_W - 1:0] data_GPRin;
    wire [DATA_W - 1:0] data_GPRout;
    wire [ADDR_W - 1:0] addr_GPR;
    wire [DATA_W - 1:0] data_bus;

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

    rom ROM(.data(data_in), .address(addr_out), .clk(clk), .rden(rom_rd)); 
    ram RAM(.data(data_out), .q(data_in), .address(addr_out), .clk(clk), .rden(ram_rd), .wren(ram_wr)); 
    stack STACK(.clk(clk), .opcode(opcode), .push(data_out), .pop(data_in)); 
    ALU ALU(.opcode(opcode), .data1(data_ALU0), .data2(data_ALU1), .result(data_ALUresult)); 
    GPR GPR(.GPR_wr(GPR_wr), .GPR_rd(GPR_rd), .data_in(data_GPRout), .data_out(data_GPRin), .address(addr_GPR)); 


endmodule