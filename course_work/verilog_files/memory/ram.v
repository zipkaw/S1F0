module ram #(parameter DATA_W = 14, ADDR_W = 12, DEPTH = ADDR_W**2)(
    input [DATA_W - 1:0] data, 
    input [ADDR_W - 1:0] address,
    input clk, 
    input wren,
    input rden,
    output [DATA_W - 1:0] q
);
    reg  [DATA_W - 1:0] mem [0:DEPTH-1]; 

    always @(posedge clk) begin
        if(wren)begin
            mem[address] <= data; 
        end 
    end

	 assign q = (rden) ? mem[address] : 1'bz;

    initial begin
        $readmemh("ram.mem", mem);
    end
    
endmodule