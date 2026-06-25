module data_mem #(  
    parameter DW     = 32,
    parameter DEPTH  = 64, 
    parameter AW     = $clog2(DEPTH) 
)
(
    input  wire          clk,
    input  wire          memwrite,
    input  wire          rst,

    input  wire [DW-1:0] byte_addr,
    input  wire [DW-1:0] wd,

    output wire [DW-1:0] read_data // [수정] ; 제거 및 이름 변경(rd -> read_data)
);
    
    wire [AW-1 : 0] word_addr;
    
    // 32비트 주소에서 워드 인덱스 추출 (하위 2비트 버림)
    assign word_addr = byte_addr[AW + 1 : 2];
    
    integer i;
    reg [DW-1 :0] mem [0: DEPTH -1];    

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for (i=0; i<DEPTH; i= i+1) mem[i] <= 0;
        end
        else if(memwrite) begin 
            mem[word_addr] <= wd;
        end
    end

    // 비동기 읽기 (Async Read)
    assign read_data = mem[word_addr];

endmodule