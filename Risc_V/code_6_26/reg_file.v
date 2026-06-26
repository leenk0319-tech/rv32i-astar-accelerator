`timescale 1ns/1ps

module reg_file (
    input  wire        clk_i,
    input  wire        rstn_i,
    input  wire [4:0]  RS1,
    input  wire [4:0]  RS2,
    input  wire        regwrite,
    input  wire [4:0]  W_WA,
    input  wire [31:0] W_WD,
    output wire [31:0] scr1,
    output wire [31:0] scr2
);
    reg [31:0] regs [0:31];
    integer k;


    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            for (k = 0; k < 32; k = k + 1)
                regs[k] <= 32'd0;
        end else if (regwrite && (W_WA != 5'd0)) begin
            regs[W_WA] <= W_WD;
        end
    end



    //패터슨 책 기준이면 200ns중 앞에 100ns동안 쓰고 뒤에 100ns동안 읽음 -> negedge에 읽는다 .
    // always @(negedge clk_i or negedge rstn_i) begin
    //     if (!rstn_i) begin
    //         for (k = 0; k < 32; k = k + 1)
    //             regs[k] <= 32'd0;
    //     end else if (regwrite && (W_WA != 5'd0)) begin
    //         regs[W_WA] <= W_WD;
    //     end
    // end



    //바이패스형태로 구현 -> 평상시에 읽을때랑 쓰는값이 다르면 그냥 한 clk뒤에 가게끔 구현
    // W_WA 랑 RS1또는 RS2가 같은 경우 즉 쓸값이랑 읽을 값이랑 같은 경우가 핵심 !
    // -> 이경우에는 같은경우:W_WD를 바로 가져가게 구현 같지않으면 평상시 (regs[RS_1]로 가져가게끔 구현)
     assign scr1 = (RS1 == 5'd0) ? 32'd0 :
                  (regwrite && (W_WA != 5'd0) && (W_WA == RS1)) ? W_WD :
                  regs[RS1];

    assign scr2 = (RS2 == 5'd0) ? 32'd0 :
                  (regwrite && (W_WA != 5'd0) && (W_WA == RS2)) ? W_WD :
                  regs[RS2];

endmodule
