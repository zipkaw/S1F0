
module pipelined_control #(
   parameter DATA_W = 14, 
   parameter ADDR_W = 12
)(
    input clk, reset, pause_READ, pause_DECODE, pause_WRITE,
    input [DATA_W*2-1:0] command_in,

    output ram_garant_rd,    
    output ram_garant_wr,
    output rom_garant_rd,
    input [DATA_W - 1:0] data_in,
    output [ADDR_W - 1:0] addr_out,
    output [DATA_W - 1:0] data_out,

    output comm_write,
    output comm_read,
    
    output GPR_rd,
    output [ADDR_W-1:0] addr_GPRin,
    input [DATA_W - 1:0] data_GPRin,
    output GPR_wr,
    output [ADDR_W-1:0] addr_GPRout,
    input [DATA_W - 1:0] data_GPRout,
    
    output [3:0] opcode,

    output [DATA_W+ADDR_W + 4 - 1 : 0] complex_data,
    output data_write,
    input [DATA_W+ADDR_W + 4 - 1 : 0] DAO,
    output data_read
    
);
    wire rom_rd, ram_rd, ram_wr;
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
        .pause_WRITE(pause_WRITE),
        .comm_read(comm_read),
        .command_in(command_in),
		
        .ram_garant_rd(ram_garant_rd),
        .addr_out(addr_out),
        .data_in(data_in),
        .ram_rd(ram_rd),

        .opcode(opcode),

        .data_GPRin(data_GPRin),
        .GPR_rd(GPR_rd),
        .addr_GPRin(addr_GPRin),

        .complex_data(complex_data),
        .data_write(data_write)
    );

    WRITE WRITE(
        .clk(clk), 
        .reset(reset),
        .DAO(DAO),
        .data_read(data_read),
        
        .GPR_wr(GPR_wr), 
        .data_GPRout(data_GPRout),
        .addr_GPRout(addr_GPRout),

        .ram_wr(ram_wr),
        .ram_garant_wr(ram_garant_wr),
        .data_out(data_out),
        .addr_out(addr_out)
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



