module stack #(parameter VOLUME = 12, DATA_W = 12)(
    input clk, 
    input [3:0] opcode,
    input reset, 
    input [DATA_W - 1:0] push, 
    output reg [DATA_W - 1:0] pop
    
);
    reg [DATA_W - 1:0] data[VOLUME -1:0]; 
    reg [VOLUME - 1:0] pointer; 
    
    always @(posedge clk) begin
		if (reset)
			pointer <= 0;
	end
    
    always @(posedge clk) begin
        if (opcode == `OP_PUSH_R) begin
            data[pointer] <= push;
            pointer <= pointer + 1;
        end
        if (opcode == `OP_POP_R) begin
            pop <= data[pointer];
            pointer <= pointer - 1;
        end
    end
endmodule