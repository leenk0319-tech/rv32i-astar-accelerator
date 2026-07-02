// load-use hazard detect
// ID/EX: memread, rd
// IF/ID: rs1, rs2
// output:
// - IF_ID_write = 0
// - PCwrite = 0
// - bubble = 1 for ID/EX bubble insertion

module hazard_detect(
    input [4:0] f_d_r1,f_d_r2,
    input use_rs1,
    input use_rs2,
    input [4:0] d_e_rd,
    input memread, // load instruction check signal
    output reg PCwrite_load,
    output reg IF_ID_write_load,
    output reg bubble
);
    always @(*) begin
        if (memread && d_e_rd != 5'd0 &&
            ((use_rs1 && (f_d_r1 == d_e_rd)) || (use_rs2 && (f_d_r2 == d_e_rd)))) begin
            PCwrite_load = 1'd0;
            IF_ID_write_load= 1'd0;
            bubble =1'd1;
        end
        else begin
            PCwrite_load = 1'd1;
            IF_ID_write_load = 1'd1;
            bubble =1'd0;
        end
    end

endmodule
