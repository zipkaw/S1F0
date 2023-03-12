module rom #(parameter DATA_W = 14, ADDR_W = 12, DEPTH = ADDR_W**2)(
    output reg [DATA_W - 1:0] data, 
    input [ADDR_W - 1:0] address,
    input clk, 
    input rden,
);
    reg  [DATA_W - 1:0] mem [DEPTH-1:0]; 

    always @(posedge rden ) begin
        data <= mem[address];  
    end
    
    initial begin
        $readmemh("rom.hex", mem);
    end

endmodule