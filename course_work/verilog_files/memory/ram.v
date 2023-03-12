module ram #(parameter DATA_W = 14, ADDR_W = 12, DEPTH = ADDR_W**2)(
    input [DATA_W - 1:0] data, 
    input [ADDR_W - 1:0] address,
    input clk, 
    input wren, 
    input rden,

    output reg[DATA_W - 1:0] q;
);
    reg  [DATA_W - 1:0] mem [DEPTH-1:0]; 

    always @(posedge clk) begin
        if(wren)begin
            mem[address] <= data; 
        end 
    end

    always @(posedge rden) begin
        q <= mem[address]; 
    end
    
    initial begin
        $readmemh("ram.hex", mem);
    end
    
endmodule