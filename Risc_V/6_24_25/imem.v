module imem #(  
    parameter INIT_FILE = "program.hex",  //파일 명
    parameter DEPTH = 1024                // 레지스터 개수 
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:DEPTH-1];  //개수가 depth개 
    
    initial begin
        $readmemh(INIT_FILE, mem);  //program.hex 읽어서 mem에 채우는 방식을 활용함. hex : 16진수라는 뜻    
    end
    assign instr = mem[addr[11:2]]; //2^10승 :1024

endmodule