`include "./opcodes.v"
module commands_rom #(
    parameter DATA_W = 14, 
    parameter ADDR_W = 12,
    parameter REGS = 16
) (
    input clk, reset,
    input [DATA_W-1:0] command_in,
    input comm_write, comm_read, 

    output reg [DATA_W*2-1:0] command_out,
    output reg pause_READ, 
    output reg pause_DECODE,

    output reg [ADDR_W - 1:0] jmp_addr
);
    /*
        data format {14 bytes of data },{0/1 byte of sign}
        the sign 1 means that data needed send to DECODE 
        0 means that data needed repair new one.
    */
    reg [DATA_W:0]commands[0:REGS-1]; 
    reg [3:0] command_counter;
    reg [3:0] to_read_command; 
    localparam DECODE_LAT = 1;
    reg [1:0] latency_counter; 
    reg start_DECODE;
	integer i;
    reg [3:0] state_jmp;
    reg [3:0] comm_jmp;
    reg [ADDR_W-1:0] addr_to_jmp;
    initial begin
        jmp_addr <= 12'bzzzzzzzzzzzz;
		pause_READ <= 0;
		pause_DECODE <= 1;
        start_DECODE <= 0;
        for(i = 0; i<REGS; i = i + 1) begin
            commands[i] = {14'bxxxxxxxxxxxxxx, 1'b0};
        end
    end
    
 
    always @(negedge comm_write) begin
        if ({commands[0][0], commands[0][0]}== 2'b11) begin
            pause_DECODE <= 0;
        end
        state_jmp <= command_counter-2;
        comm_jmp <= commands[state_jmp][DATA_W:DATA_W-3];
        addr_to_jmp <= {commands[state_jmp][DATA_W - 9:1], commands[state_jmp+1][DATA_W:DATA_W - 5]};
    end
    
    always @(posedge clk) begin
        case(comm_jmp)
            `OP_JMP: begin
                jmp_addr <= addr_to_jmp;
            end
            `OP_JNZ: begin
                jmp_addr <= addr_to_jmp;
            end
            default: begin
                jmp_addr <= 12'b111111111111; 
            end
        endcase
    end
    

    always @(negedge clk) begin
        if(reset) begin
            command_counter <= 4'd0;
            to_read_command <= 4'd0;
        end else begin
            if(comm_write) begin
                if(commands[command_counter][0] == 1'b0) begin
                    pause_READ <= 1'b0;
                    commands[command_counter] <= {command_in, 1'b1};
                    command_counter <= 1 + command_counter;
                end else begin
                    pause_READ <= 1'b1;
                end
            end
            if(comm_read == 1'b1) begin
                if(commands[to_read_command][0] == 1'b1)begin
                    command_out <= {commands[to_read_command+1][DATA_W:1], commands[to_read_command][DATA_W:1]}; 
                    commands[to_read_command]   <= {14'bxxxxxxxxxxxxxx, 1'b0};
                    commands[to_read_command+1] <= {14'bxxxxxxxxxxxxxx, 1'b0};
                    to_read_command <= 2 + to_read_command; 
                end
            end
        end
    end
endmodule