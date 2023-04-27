`include "opcodes.v"
`include "/home/plantator/SIFO/course_work/verilog_files/memory/rom.v"
`include "/home/plantator/SIFO/course_work/verilog_files/memory/ram.v"
`include "/home/plantator/SIFO/course_work/verilog_files/memory/mem_resolver.v"
`include "./commands_ram.v"
`include "./commands_rom.v"
`include "./stack.v"
`include "./GPR.v"
`include "./ALU.v"
`include "./READ_ROM.v"
module cpu #(
    parameter DATA_W = 14, ADDR_W = 12
) (
    input clk,
    input reset
);
    wire [DATA_W - 1:0] data_in;
    wire [DATA_W - 1:0] data_out;
    wire [ADDR_W - 1:0] addr_out;
    wire [DATA_W*2 - 1:0] command_out;
    wire rom_rd_garant;
    wire ram_garant_rd;
    wire ram_garant_wr;

    wire comm_write;
    wire comm_read;
    wire pause_READ;
    wire pause_WRITE;
    wire pause_DECODE;

    wire [DATA_W+ADDR_W + 4 - 1 : 0] complex_data;
    wire [DATA_W+ADDR_W + 4 - 1 : 0] DAO;
    wire data_write;
    wire data_read;

    wire [3:0] opcode;

    wire [DATA_W - 1:0] data_GPRin;
    wire [DATA_W - 1:0] data_GPRout;
    wire [ADDR_W - 1:0] addr_GPRout;
    wire [ADDR_W-1:0] addr_GPRin;
    wire GPR_rd;
    wire GPR_wr;

    wire [DATA_W-1:0] data_ALU1, data_ALU0, data_ALUresult;
    wire [ADDR_W-1:0] jmp_addr;

    wire [DATA_W-1:0] data_stack_pop, data_stack_push;

    pipelined_control control(
        .clk(clk),
        .reset(reset),

        .command_in(command_out),
        .comm_write(comm_write),
        .comm_read(comm_read),
        .pause_READ(pause_READ), 
        .pause_DECODE(pause_DECODE),
        .pause_WRITE(pause_WRITE),

        .addr_out(addr_out),
        .data_in(data_in),
        .data_out(data_out),
        .rom_garant_rd(rom_rd_garant),
        .ram_garant_rd(ram_garant_rd),
        .ram_garant_wr(ram_garant_wr),

        .GPR_rd(GPR_rd),
        .addr_GPRin(addr_GPRin),
        .data_GPRin(data_GPRin),
        .GPR_wr(GPR_wr),
        .addr_GPRout(addr_GPRout),
        .data_GPRout(data_GPRout),

        .data_ALU0(data_ALU0), 
        .data_ALU1(data_ALU1), 
        .data_ALUresult(data_ALUresult),

        .opcode(opcode),

        .complex_data(complex_data),
        .data_write(data_write) ,
        .DAO(DAO),
        .data_read(data_read),

        .jmp_addr(jmp_addr),

        .data_stack_pop(data_stack_pop),
        .data_stack_push(data_stack_push)
    );

    commands_rom rom_reg(
        .clk(clk), 
        .reset(reset),
        .command_in(data_in),
        .comm_write(comm_write), 
        .comm_read(comm_read), 
        .command_out(command_out),
        .pause_READ(pause_READ), 
	    .pause_DECODE(pause_DECODE),

        .jmp_addr(jmp_addr)
    );

    commands_ram ram_reg(
        .clk(clk), 
        .reset(reset),
        .data_in(complex_data),
        .data_out(DAO),
        .comm_write(data_write),
        .comm_read(data_read),
        .pause_DECODE(pause_DECODE),
        .pause_WRITE(pause_WRITE)
    );
	 
    rom ROM(
        .address(addr_out),
        .clk(clk), 
        .rden(rom_rd_garant),
        .data(data_in)
        ); 
    
    ram RAM(
       .address(addr_out),
       .clk(clk), 
       .data(data_out),
       .wren(ram_garant_wr),
       .rden(ram_garant_rd),
       .q(data_in)
       );

    GPR GPR(
        .clk(clk),
        .address_in(addr_GPRout), 
        .address_out(addr_GPRin), 
        .data_in(data_GPRout), 
        .data_out(data_GPRin), 
        .GPR_rd(GPR_rd), 
        .GPR_wr(GPR_wr)
    );

    ALU ALU(
        .data0(data_ALU0), 
        .data1(data_ALU1), 
        .opcode(opcode),
        .result(data_ALUresult)
    );

    stack stack(
        .clk(clk),
        .reset(reset), 
        .opcode(opcode),
        .push(data_stack_push), 
        .pop(data_stack_pop)
    );


endmodule