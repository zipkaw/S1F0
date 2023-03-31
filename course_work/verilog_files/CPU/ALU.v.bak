module ALU #(parameter DATA_W = 12)(
    input [DATA_W - 1:0] data1, 
    input [DATA_W - 1:0] data2, 
    input [3:0] opcode,
    output reg [DATA_W - 1:0] result
);
    always @(*) begin
        case (opcode)
            `OP_INC_SR, `OP_INC_BIO:
            begin
                result <= data1 + 1'b1;
            end
            `OP_NAND_SR, `OP_NAND_BIO: 
            begin
                result <= ~(data1 & data2);
            end
            `OP_SRA_BIO, `OP_SRA_SR:
            begin
                result <= data1 >>> data2;
            end
            `OP_XOR_BIO, `OP_XOR_SR: 
            begin
                result <= data1 ^ data2;
            end
        endcase
    end
    
endmodule