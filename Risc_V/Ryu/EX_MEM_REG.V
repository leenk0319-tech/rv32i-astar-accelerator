# PDF 발췌 코드 설명 (SystemVerilog)

아래 내용은 `CompanionAsset_9780128203316_Ch05_e2.pdf`의 cache 예제 코드를 기준으로 정리한 것입니다.
저장된 실제 코드는 `cache_controller_extracted.sv`입니다.

## 1) `struct packed`가 왜 중요한가

Verilog만 쓰다가 SystemVerilog로 넘어오면 가장 먼저 헷갈리는 부분이 `typedef struct packed`입니다.

- `struct`: 서로 관련된 신호를 묶어서 "한 타입"으로 다룸
- `packed`: 비트 단위로 연속 배치됨
- 장점: 포트가 깔끔해지고, 의미 단위로 묶여 가독성이 크게 좋아짐

예시:

```systemverilog
typedef struct packed {
  bit [31:0] addr;
  bit [31:0] data;
  bit        rw;
  bit        valid;
} cpu_req_type;
```

위 구조체 하나로 `addr/data/rw/valid`를 한 번에 전달할 수 있습니다.

## 2) 코드 안의 핵심 구조체

- `cache_tag_type`: tag RAM 한 칸(태그/valid/dirty)
- `cache_req_type`: RAM 접근 제어(we/index)
- `cpu_req_type`: CPU에서 cache로 들어오는 요청
- `cpu_result_type`: cache에서 CPU로 나가는 응답
- `mem_req_type`: cache에서 메모리로 나가는 요청
- `mem_data_type`: 메모리에서 cache로 들어오는 데이터

이런 식으로 인터페이스를 구조체로 묶으면 배선 실수가 줄고, 모듈 경계가 선명해집니다.

## 3) 전체 블록 구성

```text
CPU req
  |
  v
+-------------------+
|   dm_cache_fsm    |<------------------- mem_data (ready,data)
|  (상태기계 컨트롤) |-------------------> mem_req  (valid,rw,addr,data)
+---------+---------+
          |
          | tag_req/tag_write <-> tag_read
          v
     dm_cache_tag

          |
          | data_req/data_write <-> data_read
          v
     dm_cache_data
```

## 4) FSM 동작 흐름

```text
        +------+
        | idle |
        +--+---+
           |
           | cpu_req.valid
           v
   +---------------+
   |  compare_tag  |
   +---+-------+---+
       |       |
   hit |       | miss
       |       v
       |   victim clean/invalid ------> +----------+
       |                                | allocate |
       |                                +----+-----+
       |                                     |
       |                                     | mem_data.ready
       |                                     v
       |                                compare_tag (재시도)
       |
       +--> (write hit면 data/tag 갱신 후) idle

miss + victim dirty -> +------------+
                       | write_back |
                       +-----+------+
                             |
                             | mem_data.ready
                             v
                          allocate
```

## 5) 주소 분해 포인트

- `addr[31:14]`: tag
- `addr[13:4]`: index (1024 엔트리라 10비트)
- `addr[3:2]`: 128-bit 라인 내부 32-bit word 선택
- `addr[1:0]`: byte offset

코드에서 `case (cpu_req.addr[3:2])`로 4개 word 중 어떤 word를 읽고/쓰는지 선택합니다.

## 6) Verilog 스타일로 이해하는 팁

- `always_ff`: "순차 로직(플립플롭)" 전용 블록
- `always_comb`: "조합 로직" 전용 블록
- `typedef struct packed`: "버스 묶음"

즉, 기존 Verilog 감각으로 보면:
- `always_ff` = `always @(posedge clk)` 역할
- `always_comb` = `always @(*)` 역할
- `struct packed` = 신호 묶음 버전의 큰 벡터 + 필드명 접근

## 7) 참고

PDF 텍스트 추출 특성상 원문 줄바꿈/공백은 일부 깨질 수 있어, `cache_controller_extracted.sv`는
원문 구조를 유지하면서 컴파일 가능한 형태로 정리했습니다.
