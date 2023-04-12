module rom #(parameter DATA_W = 14, ADDR_W = 12, DEPTH = ADDR_W**2)(
    input [ADDR_W - 1:0] address,
    input clk, 
    input rden,
    output [DATA_W - 1:0] data
);
    reg  [DATA_W - 1:0] mem [DEPTH-1:0]; 

	assign data = (rden) ? mem[address] : 14'bzzzzzzzzzzzzzz;
    
    initial begin
        $readmemb("rom.mem", mem);
    end
endmodule