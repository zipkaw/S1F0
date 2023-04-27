module mem_resolver (
    input clk, reset,

    input rom_rd, 
    input ram_rd,
    input ram_wr, 

    output reg rom_garant, 
    output reg ram_garant_rd, 
    output reg ram_garant_wr
);

    reg [1:0] busy_state; 
    initial begin 
        busy_state <= 0;
        rom_garant <=0;
        ram_garant_rd <=0;
        ram_garant_wr <=0;
    end

    /*For debug*/
    // always @(*) begin
    //     rom_garant <=rom_rd;
    //     ram_garant_rd <=ram_rd;
    //     ram_garant_wr <=ram_wr;
    // end

    always @(negedge clk) begin
        if(reset) begin
            busy_state <= 0;
        end else begin
            if(busy_state == 2'b00) begin
                casex ({rom_rd, ram_rd, ram_wr})
                3'b1xx: begin
                    busy_state <= 2'd1;
                    rom_garant <= 1; 
                end
                3'bx1x: begin
                    busy_state <= 2'd2;
                    ram_garant_rd <= 1;
                end
                3'bxx1: begin
                    busy_state <= 2'd3;
                    ram_garant_wr <= 1;
                end
            endcase
            end 
				if(busy_state != 2'b00) begin 
            casex ({rom_rd, ram_rd, ram_wr, busy_state})
                5'b0xx01: begin
                    rom_garant <= 0;
                    busy_state <= 2'b00;
                end
                5'bx0x10: begin
                    ram_garant_rd <= 0;
                    busy_state <= 2'b00;
                end
                5'bxx011: begin
                    ram_garant_wr <= 0;
                    busy_state <= 2'b00;
                end
            endcase
        end
        end
    end

endmodule