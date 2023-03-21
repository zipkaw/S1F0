
`timescale 1ps/1ps

module ram_tb;

    localparam DATA_W = 14;
    localparam ADDR_W = 12; 

	 //reg [DATA_W -1:0] q;
    reg [DATA_W -1:0] data;
    reg [ADDR_W -1:0] address; 
    reg clk; 
    reg rden; 
    reg wren; 
	
    ram uut(.data(data), .address(address), .clk(clk), .rden(rden), .wren(wren)	);

    initial begin
        clk = 0; 
        wren = 0; 
        data = 0; 

        address = 4; 
        rden = 1'b1;
        #10
        address = 0; 
        rden = 1'b0;
        #10
        address = 4; 
        data = 3; 
        wren = 1'b1; 
        #10
        address = 0; 
        data = 0; 
        wren = 1'b0; 
        #10
        address = 4; 
        wren = 1'b0; 

        rden = 1'b1; 
    end

    initial begin
        #100 $stop; 
    end
    
    always begin
        #5
        clk = ~clk; 
    end

endmodule