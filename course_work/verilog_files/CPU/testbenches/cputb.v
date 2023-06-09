`timescale 1ps/1ps

module cputb; 
    localparam DATA_W = 14;
    localparam ADDR_W = 14;
    reg clk, reset;

    cpu UUT(.clk(clk), 
				.reset(reset)); 
    initial begin
        clk = 0;
		  reset = 0;
		  end
    initial begin
        #5 reset <= 1'b1; 
        #5 reset <= 1'b0; 
    end
    always begin
        #5
        clk = ~clk; 
    end

    initial begin
        #100 $stop;
    end

endmodule