

module pipelined_control #(
   parameter DATA_W = 14, 
   parameter ADDR_W = 12
)(
    input clk, reset, pause_READ,
    /*output on general bus*/
    output [ADDR_W - 1:0] addr_out,
    output comm_write,
    /* control bus*/ 
    output rom_rd
);
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
        .pause_READ(pause_READ)
    );

endmodule



