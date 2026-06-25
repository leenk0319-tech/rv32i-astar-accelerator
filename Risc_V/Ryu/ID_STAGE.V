module br_cond
#(parameter DW =32)
(   
    input branch,
    input [1:0]    condsrc1,
    input [1:0]    condsrc2,
    input [DW-1:0] rf_out1,
    input [DW-1:0] rf_out2,
    input [DW-1:0] ex_mem_out,
    input [DW-1:0] mem_wb_out,

    output is_branch
);  
localparam rf_to_cond = 2'b00;
localparam ex_mem_to_cond =2'b01;
localparam mem_wb_to_cond =2'b10;
reg [DW-1: 0] cond_data1;
reg [DW-1: 0] cond_data2;

assign is_branch = ((cond_data1 == cond_data2) && branch);


always @(*)begin
    case(condsrc1) 

    rf_to_cond     : cond_data1 = rf_out1;
    ex_mem_to_cond : cond_data1 = ex_mem_out;
    mem_wb_to_cond : cond_data1 = mem_wb_out;
    default : cond_data1 = rf_out1;
    endcase
    case(condsrc2) 

    rf_to_cond     : cond_data2 = rf_out2;
    ex_mem_to_cond : cond_data2 = ex_mem_out;
    mem_wb_to_cond : cond_data2 = mem_wb_out;
    default : cond_data2 = rf_out2;
    endcase

end
    
endmodule