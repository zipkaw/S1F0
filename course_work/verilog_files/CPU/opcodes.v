/* 

Addressations:
    BIO - Base Index Offset
    SR - Straight Register
    SA - Straight Address
    
    R - Register
*/

`define OP_MOV_SR   4'd1
`define OP_MOV_SA   4'd2
`define OP_MOV_BIO  4'd3
`define OP_INC_SR   4'd4
`define OP_INC_BIO  4'd5
`define OP_XOR_SR   4'd6
`define OP_XOR_BIO  4'd7
`define OP_NAND_SR  4'd8
`define OP_NAND_BIO 4'd9
`define OP_SRA_SR   4'd10
`define OP_SRA_BIO  4'd11
`define OP_PUSH_R   4'd12
`define OP_POP_R    4'd13
`define OP_JNZ      4'd14
`define OP_JMP      4'd15
`define OP_HLT      4'd0