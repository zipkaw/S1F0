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

// Other Registers 
`define REG_AX1    4'd8
`define REG_AX2   4'd9
`define REG_AX3   4'd10
`define REG_AX4   4'd11
`define REG_AX5   4'd12
`define REG_AX6   4'd13
`define REG_AX7   4'd14
`define REG_F     4'd15

module GPR #(
    parameter DATA_W = 14, ADDR_W = 12, REG_N = 16, REG_W = 4
) (
    input clk,
    input [ADDR_W - 1:0] address_in, 
    input [ADDR_W - 1:0] address_out, 
    input [DATA_W - 1:0] data_in, 
    output reg [DATA_W - 1:0] data_out,
    input GPR_rd,
    input GPR_wr
);
    reg [DATA_W - 1:0] registers[REG_N - 1:0]; 
    localparam reg_offset = ADDR_W - 1;
    always @(*) begin
        if (GPR_wr) begin
            registers[address_in[ADDR_W-1:ADDR_W - REG_W]] <= data_in; 
        end
        else if (GPR_rd) begin
            data_out <= registers[address_out[ADDR_W - 1: ADDR_W - REG_W]] + 
                        registers[address_out[ADDR_W - 1 - REG_W : ADDR_W - 2 * REG_W]] + 
                        registers[address_out[ADDR_W - 1 - 2*REG_W : ADDR_W - 3 * REG_W]];
        end
    end

    always @(posedge clk) begin
        registers[`REG_F] = registers[`REG_F] ^ 14'b00000000000001;

    end

    initial begin
        $readmemh("GPR.mem", registers);
    end
endmodule