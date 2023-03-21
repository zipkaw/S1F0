`timescale 1ps/1ps

module controltb; 

    reg clk, reset;
    reg [DATA_W - 1:0] data_in;
    reg [ADDR_W - 1:0] addr_in;
    /*output on general bus*/
    reg [DATA_W - 1:0] data_out;
    reg [ADDR_W - 1:0] addr_out;
    /* control bus*/
    reg [3:0] opcode;
    
    reg rom_rd;
    reg ram_rd;
    
    reg ram_wr;
    
    reg GPR_rd;
    reg GPR_wr;
    /*output on ALU bus*/
    reg [DATA_W - 1:0] data_ALU0;
    reg [DATA_W - 1:0] data_ALU1;
    reg [DATA_W - 1:0] data_ALUresult;

    /*output and input on GPR bus*/
    reg [DATA_W - 1:0] data_GPRin;
    reg [DATA_W - 1:0] data_GPRout;
    reg [ADDR_W - 1:0] addr_GPR;

    wire [DATA_W - 1:0] data_bus;

    control UUT(); 
    rom ROM(); 
    ram RAM(); 
    stack STACK(); 
    ALU ALU(); 
    GPR GPR(); 
    
    initial begin
        
    end


    initial begin
        #1000 $stop;
    end
    always begin
        #5
        clk = ~clk; 
    end


endmodule