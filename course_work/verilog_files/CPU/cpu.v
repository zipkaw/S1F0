module cpu #(
    parameter DATA_W = 14, ADDR_W = 12
) (
    input clk,
    input reset
);

    wire [DATA_W - 1:0] data_bus; 

    /* 
        rom and ram is outside and connected with general data_bus
        information from data in and data out come to  data_bus
    */

    /* in feature there will be cache */ 
    ram RAMmodule();
    rom ROMmodule(); 
    
    /* 
        stack is inside but connected to general bus
    */
    stack STACK();
    /*
        this modules are inside cpu module and connected with own bus
    */

    GPR GPRmodule(); 
    ALU ALUmodule();


    /*
        control unit connected all modules together
        control signals: 
            -[3:0]opcodes
            -ram_rd, ram_wr
            -rom_rd
            -GPR_rd, GPR_wr
        data buses:
            - ALU0, ALU1, ALUresult
            - GPRin, GPRout 
            - data_in, data_out
        addres buses: 
            - addr_GPR
            - addr_out
    */
    control CU(); 
    

endmodule