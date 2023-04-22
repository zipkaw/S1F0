module READ_ROM #(
    parameter DATA_W = 14, 
    parameter ADDR_W = 12
) (
    input clk, reset, pause_READ,
    input rom_rd_garant,
    output reg rom_rd,
    output reg command_write,
    output reg [ADDR_W - 1:0] addr_out
);
    reg [DATA_W - 1:0] command;
    reg [ADDR_W - 1:0] IP;
    reg [3:0] latency_counter; 
    
    reg [7:0] state; 
    localparam INIT = 0, READ =1;
    localparam READ_LAT = 2;
    reg wait_sig;

    always @(posedge clk) begin
        if (reset) begin
            latency_counter <= 0;
            IP <= 0;
            rom_rd <= 1'b0;
            command_write <= 1'b0; 
            state <= INIT;
            wait_sig <= 0; 
        end else if(pause_READ == 1'b0) begin
            if(latency_counter != 0 && wait_sig == 0) begin
                latency_counter <= latency_counter - 1'b1;
            end
            case(state)
                INIT: begin
                    latency_counter <= READ_LAT; 
                    state <= READ; 
                    command_write <= 1'b0; 
                end
                READ: begin
                    if (latency_counter == 0) begin
                        state <= INIT;
                        addr_out <= 12'bzzzzzzzzzzzz;
                        rom_rd <= 1'b0;
                        command_write <= 1'b0;
                    end else begin
                        rom_rd <= 1'b1;
                        if(rom_rd_garant == 1) begin
                            wait_sig <= 0;
                            addr_out <= IP;
                            command_write <= 1'b1; 
                            IP <= IP + 1; 
                        end else begin
                            wait_sig <= 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule