module control #(
    parameters
) (
    ports
);

    reg [3:0]cnt; 
    always @(posedge clk ) begin
        cnt <= cnt+1;
    end

    case (cnt)
        : 
        default: 
    endcase
    
endmodule