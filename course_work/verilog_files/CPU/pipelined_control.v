
module pipelined_control #(
   parameter DATA_W = 14, 
   parameter ADDR_W = 12
)(
    input clk, reset, pause_READ, pause_DECODE,
    input [DATA_W*2-1:0] command_in,
	input ram_garant_rd,
    input rom_garant_rd,
    input [DATA_W - 1:0] data_in, 

    output [ADDR_W - 1:0] addr_out,
    output comm_write,
    output comm_read,
    
    output GPR_rd,
    output [ADDR_W-1:0] addr_GPRin,
    input [DATA_W - 1:0] data_GPRin
    
    output [3:0] opcode,
);
    wire rom_rd, ram_rd, ram_wr;
    assign ram_wr = 1'bx;
    /*
    first step of pipeline 
    read rom and write commands
    in "commands_rom"
    */
    READ_ROM READ_ROM(
        .clk(clk),
        .reset(reset),
        .rom_rd(rom_rd),
        .command_write(comm_write),
        .addr_out(addr_out),
        .pause_READ(pause_READ),
        .rom_rd_garant(rom_garant_rd)
    );
    /*
        second step is read 
        commands decode opcode and 
        read data to write
    */
    DECODE DECODE(
        .clk(clk),
        .reset(reset),

        .pause_DECODE(pause_DECODE),
        .comm_read(comm_read),
        .command_in(command_in),
		
        .ram_garant_rd(ram_garant_rd),
        .addr_out(addr_out),
        .data_in(data_in),
        .ram_rd(ram_rd),

        .opcode(opcode),

        .data_GPRin(data_GPRin),
        .GPR_rd(GPR_rd),
        .addr_GPRin(addr_GPRin)
    );

    mem_resolver mem_resolver(
        .clk(clk), 
        .reset(reset),

        .rom_rd(rom_rd), 
        .ram_rd(ram_rd),
        .ram_wr(ram_wr), 

        .rom_garant(rom_garant_rd), 
        .ram_garant_rd(ram_garant_rd), 
        .ram_garant_wr(ram_garant_wr)
    );

endmodule



