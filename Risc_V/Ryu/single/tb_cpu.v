`timescale 1ns / 1ps

module tb_TOP_SC_CPU();

    // 1. 테스트할 신호들 선언
    parameter DW = 32;
    
    reg                 clk;
    reg                 rst;
    reg                 PC_en;
    
    wire [DW-1 : 0]     debug_result;
    wire [DW-1 : 0]     debug_PC;
    wire [3:0]          flag;

    // 2. 송봉님의 Top Module 불러오기 (인스턴스화)
    TOP_SC_CPU #(.DW(DW)) dut (
        .rst(rst),
        .clk(clk),
        .PC_en(PC_en),
        .debug_result(debug_result),
        .debug_PC(debug_PC),
        .flag(flag)
    );

    // 3. 클럭(Clock) 생성: 10ns 주기 (100MHz)
    always #5 clk = ~clk;

    // 4. 시뮬레이션 시나리오 (자극 주기)
    initial begin
        // 초기 상태 세팅
        clk = 0;
        rst = 1;       // 리셋 ON (PC를 0으로 묶어둠)
        PC_en = 0;     // PC 동작 허용
        
        $display("========================================");
        $display("   RISC-V Single Cycle CPU Test Start!  ");
        $display("========================================");

        // 15ns 대기 후 리셋 풀기 (이때부터 CPU가 달리기 시작함!)
        #15; 
        rst = 0;   
        PC_en = 1;
        // 프로그램이 끝날 때까지 충분히 대기 (약 200ns)
        #600;
        
        $display("========================================");
        $display("   Simulation Finished. Check Waveforms!");
        $display("========================================");
        $finish; // 시뮬레이션 강제 종료
    end

    // 5. 실시간 모니터링 (콘솔창에 출력)
    initial begin
        // 클럭이 뛸 때마다 PC 값과 결과를 텍스트로 찍어줍니다.
        $monitor("Time: %3t ns | RST: %b | PC: %h | Result(ALU/MEM): %h | Flag: %b", 
                 $time, rst, debug_PC, debug_result, flag);
    end

endmodule