//양자화 된 INT8 data를 받는다고 가정하자.
module PE_UNIT
#(parameter DW = 8)
(
    input clk,
    input rst,
    input en,
  	input load,

  input [2*DW-1:0] up_in,
    input [DW-1:0] left_in,
  input [DW-1:0] weight,

  output reg [DW-1:0]  right_out,
  output reg  [2*DW-1:0]  down_out


);

reg [DW-1:0] PE;
  always @(posedge clk, posedge rst)begin
    if(rst)  begin PE <= {DW{1'b0}}; right_out <={DW{1'b0}};down_out <= {2*DW{1'b0}}; end 

else begin 
  if(load) PE <= weight;
  if(en) begin
    right_out <= left_in;
    down_out  <= left_in*PE + up_in;
    
  end
end 
end 
endmodule

module systolic_array
#(parameter DW= 8,parameter ROW =4, parameter COL = 4)
(
    input clk,
    input en,
    input rst,
    input load,
    input [(ROW*COL*DW)-1:0] weight,
    input [ROW*DW-1:0] left_in,
    output [COL*2*DW-1 : 0] mac
);
localparam LW = 2*DW;
genvar row;
genvar col;

wire [DW-1:0] weight_PE[0:ROW-1][0:COL-1];
wire [DW-1:0] wire_row[0:ROW-1][0:COL];
wire [LW-1:0] wire_col[0:ROW][0:COL-1];

genvar g;
generate
for(g=0; g < COL; g= g+1) begin :row_loop 
    assign wire_col[0][g] = {LW{1'b0}};
    assign mac[g*LW +:LW] = wire_col[ROW][g];
end
for(g=0; g < ROW; g= g+1) begin :cool_loop
    assign wire_row[g][0] = left_in[DW*g +:DW];end     
endgenerate

generate
    for(row = 0; row <ROW ; row= row +1)begin :loop1
        for(col = 0; col < COL ; col = col + 1)begin:loop2
        assign weight_PE[row][col] = weight[DW*((row*COL)+col)+:DW];
PE_UNIT #(.DW(DW))pe_array

(
    .clk(clk),
    .rst(rst),
    .en(en),
  	.load(load),

  .up_in(wire_col[row][col]),
  .left_in(wire_row[row][col]),
  .weight(weight_PE[row][col]),
  .right_out(wire_row[row][col+1]),
  .down_out(wire_col[row+1][col])

);


        end
    end


endgenerate


endmodule

    module step_FF #(
        parameter DW = 8, parameter ROW =4 , parameter COL=4)
    (
        input clk,
        input en,
        input rst,
        input [DW*ROW-1 :0] data_in,
        output wire [DW*ROW-1 : 0] data_out

    );
    genvar row;
    genvar idx;
    generate
        for(row = 0; row <ROW ; row= row+1) begin :outloop
            reg [DW-1:0] ffs_wire[0:row];
            integer i;
            always@(posedge clk, posedge rst) begin
                if(rst) begin
                    
                    for(i=0; i <= row; i = i +1) ffs_wire[i] <= {DW{1'b0}};
                end
                else if (en)  begin

                    ffs_wire[0] <= data_in[DW*row +:DW];
                    for(i=0; i < row; i= i+1) ffs_wire[i+1] <= ffs_wire[i];
                    
                    end
                end
        assign data_out[row*DW +: DW] = ffs_wire[row];
    end

    endgenerate    


    endmodule



    module TOP_MM
    #(parameter DW = 32, parameter ROW = 4, parameter COL = 4)
    (
        input clk,
        input en,
        input rst,
        input load,
        
        input [(ROW*COL*DW)-1:0] weight,
        input [DW*ROW-1 :0] data_in,
        
        output [COL*2*DW-1 : 0] mac


    );
wire [ROW*DW-1:0] left_in;

systolic_array #(.DW(DW),.ROW(ROW),.COL(COL)) MAC_UNIT
(
    .clk(clk),
    .en(en),
    .rst(rst),
    .load(load),
    .weight(weight),
    .left_in(left_in),
    .mac(mac)
);

step_FF #(.DW(DW), .ROW(ROW) ,.COL(COL)) FF_UNIT
    (
        .clk(clk),
        .en(en),
        .rst(rst),
        .data_in(data_in),
        .data_out(left_in)
    );


    endmodule 