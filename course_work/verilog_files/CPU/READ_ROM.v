module READ_ROM #(
    parameter DATA_W = 14, 
    parameter ADDR_W = 12
) (
    input clk, reset, pause_READ,
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

    always @(posedge clk) begin
        if (reset) begin
            latency_counter <= 0;
            IP <= 0;
            rom_rd <= 1'b0;
            command_write <= 1'b0; 
            state <= INIT;
            pause_READ = 0;
        end

        if(pause_READ == 1'b0) begin
            if(latency_counter != 0) begin
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
                        rom_rd <= 1'b0;
                        command_write <= 1'b0;
                    end else begin
                        rom_rd <= 1'b1;
                        addr_out <= IP;
                        command_write <= 1'b1; 
                        IP <= IP + 1; 
                    end
                end
            endcase
        end
    end
endmodule