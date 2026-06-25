    module ex_fowarding 
    #(parameter AW = 5,parameter DW = 32)
    (

    input [AW-1:0] ex_mem_rd,
    input [AW-1:0] mem_wb_rd,
    input [AW-1:0] ex_rs1,
    input [AW-1:0] ex_rs2,
    input mem_regwrite,
    input wb_regwrite,
    output reg [1:0] condsrc1,
    output reg [1:0] condsrc2
    );

    always @(*)begin
        
    if ((ex_rs1 == ex_mem_rd) && mem_regwrite && ex_rs1 != 5'd0) condsrc1 = 2'b01; //dist 1 //mem에 있는 데이터가 더 최신 데이터므로, 우선 순위

    else if ((ex_rs1 == mem_wb_rd)&& wb_regwrite && ex_rs1 != 5'd0) condsrc1 = 2'b10; //dist 2 

    else condsrc1 = 2'b00;

    if ((ex_rs2 == ex_mem_rd) && mem_regwrite && ex_rs2 != 5'd0) condsrc2 = 2'b01; //dist 1//mem에 있는 데이터가 더 최신 데이터므로, 우선 순위

    else if ((ex_rs2 == mem_wb_rd)&& wb_regwrite && ex_rs2 != 5'd0) condsrc2 = 2'b10;//dist 2

    else condsrc2 = 2'b00;



    end
    endmodule