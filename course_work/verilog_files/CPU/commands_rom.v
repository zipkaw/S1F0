module commands_rom #(
    parameter DATA_W = 14, 
    parameter REGS = 16
) (
    input clk, reset,
    input [DATA_W-1:0] command_in,
    input comm_write, comm_read, 

    output reg [DATA_W*2-1:0] command_out,
    output reg pause_READ, 
    output reg pause_DECODE
);
    /*
        data format {14 bytes of data },{0/1 byte of sign}
        the sign 1 means that data needed send to DECODE 
        0 means that data needed repair new one.
    */
    reg [DATA_W:0]commands[0:REGS-1]; 
    reg [3:0] command_counter;
    reg [3:0] to_read_command; 
	 integer i;
    initial begin
		  pause_READ <= 0;
        for(i = 0; i<REGS; i = i + 1) begin
            commands[i] = {14'bxxxxxxxxxxxxxx, 1'b0};
        end
    end

    always @(negedge clk) begin
        if(reset) begin
            command_counter <= 4'd0;
            to_read_command <= 4'd0;
        end
        if(comm_write) begin
            if(commands[command_counter][0] == 1'b0) begin
                pause_READ <= 1'b0;
                commands[command_counter] <= {command_in, 1'b1};
                command_counter <= 1 + command_counter;
            end else begin
                pause_READ <= 1'b1;
            end
        end
        if(comm_read) begin
            if(commands[to_read_command][0] == 1'b1)begin
                pause_DECODE <= 1'b0; 
                command_out <= {commands[to_read_command][13:0], commands[to_read_command+1][13:0]}; 
                commands[to_read_command]   <= {14'bxxxxxxxxxxxxxx, 1'b0};
                commands[to_read_command+1] <= {14'bxxxxxxxxxxxxxx, 1'b0};
                to_read_command <= 2 + to_read_command; 
            end else begin
                pause_DECODE <= 1'b1; 
            end
        end
    end
endmodule