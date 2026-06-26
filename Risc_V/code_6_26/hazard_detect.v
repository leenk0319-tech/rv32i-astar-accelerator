// load-use hazard detect memo
// ID/EX: memread, rd
// IF/ID: rs1, rs2
// output:
// - IF_ID_write = 0
// - PCwrite = 0
// - bubble = 1 for ID/EX bubble insertion

module hazard_detect(
    input [4:0] f_d_r1,f_d_r2,
    input [4:0] d_e_rd,
    input memread, // load instruction check signal
    output reg PCwrite,
    output reg IF_ID_write,
    output reg bubble
);
    always @(*) begin
        if(( memread && d_e_rd != 5'd0 && (f_d_r1 ==  d_e_rd || f_d_r2 == d_e_rd))) begin
            PCwrite = 1'd0;
            IF_ID_write = 1'd0;
            bubble =1'd1;
        end
        else begin
            PCwrite = 1'd1;
            IF_ID_write = 1'd1;
            bubble =1'd0;
        end
    end

endmodule
