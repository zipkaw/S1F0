/*
    General Purpose Registers
*/
`define REG_AX    4'd0
`define REG_BX    4'd1
`define REG_CX    4'd2
`define REG_DX    4'd3
`define REG_SI    4'd4
`define REG_DI    4'd5
`define REG_BP    4'd6
`define REG_SP    4'd7

// Flag Register 
`define REG_FLAGS 4'd8

// Other Registers 
`define REG_AX1   4'd9
`define REG_AX2   4'd10
`define REG_AX3   4'd11
`define REG_AX4   4'd12
`define REG_AX5   4'd13
`define REG_AX6   4'd14
`define REG_AX7   4'd15


module GPR #(
    parameter DATA_W = 14, ADDR_W = 12, REG_N = 16
) (
    input clk,
    input [ADDR_W - 1:0] address, 
    inout reg [DATA_W - 1:0] data, 
    input rd, 
    input wr
);
    reg [DATA_W - 1:0] registers[REG_N - 1:0]; 
    
    always @(posedge clk) begin
        if(wr) begin
            registers[address[4:0]] <= data; 
        end
        if (rd) begin
            data <= registers[address[4:0]];
        end
    end
endmodule