    module id_fowarding 
    #(parameter AW = 5,parameter DW = 32)
    (

    input [AW-1:0] ex_rd,
    input [AW-1:0] mem_rd,
    input [AW-1:0] rf_rs1,
    input [AW-1:0] rf_rs2,
    input mem_regwrite,
    input ex_regwrite,
    output reg [1:0] condsrc1,
    output reg [1:0] condsrc2
    );

    always @(*)begin
        
    if ((rf_rs1 == ex_rd) && ex_regwrite && rf_rs1 != 5'd0) condsrc1 = 2'b01; //ex에 있는 데이터가 더 최신 데이터므로, 우선 순위

    else if ((rf_rs1 == mem_rd)&& mem_regwrite && rf_rs1 != 5'd0) condsrc1 = 2'b10;

    else condsrc1 = 2'b00;

    if ((rf_rs2 == ex_rd) && ex_regwrite && rf_rs2 != 5'd0) condsrc2 = 2'b01; //ex에 있는 데이터가 더 최신 데이터므로, 우선 순위

    else if ((rf_rs2 == mem_rd)&& mem_regwrite && rf_rs2 != 5'd0) condsrc2 = 2'b10;

    else condsrc2 = 2'b00;



    end
    endmodule