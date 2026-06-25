module alausse
(
    input clk,
    input rst,
    input en,
    input [15:0] mula,
    input [15:0] mulb,

    output reg [31:0]  res,
    output done

);

localparam idle  = 2'b00;
localparam cal   = 2'b01;
localparam Done  = 2'b10;



reg state;
reg nextstate;

  always @(posedge  clk or posedge rst) begin
  	if(rst) state <= idle;
    else state <= nextstate;
end

always @(*) begin
    nextstate = state;
    case(state)
    idle : begin if(en) nextstate = cal; end

    cal : begin
        if(tempa==32'd1) nextstate = Done;
    end
    Done :  if(!en) nextstate = idle; 

    

    endcase 
end





reg [31:0] tempa;
reg [31:0] tempb;
wire [31:0] tempc;

  assign done = (state == Done);
  
wire lsb;
assign lsb = tempa[0];
  assign  tempc = (lsb) ? tempb : 32'b0;
  always @(posedge clk) begin
   if(state == idle) begin res <= 32'b0; tempa <= mula; tempb <= mulb; end
   
   else if(state == cal)begin
     
    tempa <= tempa >>1;
    tempb <= tempb <<1;
    res <= res + tempc;

   end

end







    
endmodule