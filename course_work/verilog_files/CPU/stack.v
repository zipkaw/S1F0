`include "opcodes.v"
module stack #(parameter DATA_W = 14, VOLUME = 12)(
    input clk,
    input [3:0] opcode,
    input reset, 
    input [DATA_W - 1:0] push, 
    output reg [DATA_W - 1:0] pop
);
    reg [DATA_W - 1:0] data[VOLUME -1:0]; 
    reg [VOLUME - 1:0] pointer;
    
	always @(posedge opcode[3]) begin 
		 if (opcode == `OP_PUSH_R) begin
		     pointer <= pointer + 1'd1;
		 end 
		 if (opcode == `OP_POP_R) begin
		     pointer <= pointer - 1'd1;
		 end
	 end
	
    always @(posedge clk) begin
		if (reset) begin
			   pointer <= 0;
		end
		case(opcode)
		`OP_PUSH_R:
			data[pointer] <= push;
		`OP_POP_R:
			pop <= data[pointer];
		endcase
    end
endmodule