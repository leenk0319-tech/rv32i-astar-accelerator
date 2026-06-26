module imem #(  
    parameter INIT_FILE = "program.hex",  //파일 명
    parameter DEPTH = 1024                // 레지스터 개수 
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:DEPTH-1];  //개수가 depth개 
    
    initial begin  //initial블럭은 처음시작할 때 딱 한번 실행되는 블럭 -> 처음 시작할때 mem에다가 명령어 전부다 넣어둔다. 
        $readmemh(INIT_FILE, mem);  //program.hex 읽어서 mem에 채우는 방식을 활용함. hex : 16진수라는 뜻    
    end
    assign instr = mem[addr[11:2]]; //2^10승 :1024   // 32bit여서 <<2 (2word)

endmodule