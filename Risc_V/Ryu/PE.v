module fifo
(

input clk,
input load,
input rst,
input out,

input [15:0] data_in,

output reg [15:0] data_out


);

reg [15:0] fifo[0:15];
reg [3:0] cnt;
reg [3:0] ptr_w;
reg [3:0] ptr_r;
integer i;

always (posedge clk, posedge rst) begin
    if(rst) begin
        cnt      <= 4'd0;
        ptr_w    <= 4'd0;
        data_out <= 16'd0;
        ptr_r    <= 4'd0;
        for(i=0; i <16; i= i+1) fifo[i] <= 16'd0;
    end
    else if(load && (cnt <16)) begin
        fifo[ptr_w] <= data_in;
        ptr_w <= ptr_w + 1;
        cnt <= cnt + 1;
    end
    else if(out && (cnt >0)) begin
        data_out <= fifo[ptr_r];
        ptr_r <= ptr_r + 1;
        cnt <= cnt -1;
    end



end




endmodule