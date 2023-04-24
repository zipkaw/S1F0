`include "opcodes.v"
module ALU #(parameter DATA_W = 14)(
    input [DATA_W - 1:0] data0, 
    input [DATA_W - 1:0] data1, 
    input [3:0] opcode,
    output reg [DATA_W - 1:0] result
);
    always @(*) begin
        case (opcode)
            `OP_INC_SR, `OP_INC_BIO:
            begin
                result <= data0 + 1'b1;
            end
            `OP_NAND_SR, `OP_NAND_BIO: 
            begin
                result <= ~(data0 & data1);
            end
            `OP_SRA_BIO, `OP_SRA_SR:
            begin
                result <= data0 >>> data1;
            end
            `OP_XOR_BIO, `OP_XOR_SR: 
            begin
                result <= data0 ^ data1;
            end
        endcase
    end
    
endmodule