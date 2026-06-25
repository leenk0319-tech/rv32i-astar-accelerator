`timescale 1ns/1ps

module dm_cache_data_v (
  input              clk,
  input              data_we,
  input      [9:0]   data_index,
  input      [127:0] data_write,
  output     [127:0] data_read
);
  reg [127:0] data_mem [0:1023];
  integer i;

  initial begin
    for (i = 0; i < 1024; i = i + 1) begin
      data_mem[i] = 128'b0;
    end
  end

  assign data_read = data_mem[data_index];

  always @(posedge clk) begin
    if (data_we) begin
      data_mem[data_index] <= data_write;
    end
  end
endmodule


module dm_cache_tag_v (
  input            clk,
  input            tag_we,
  input    [9:0]   tag_index,
  input    [17:0]  tag_write_tag,
  input            tag_write_valid,
  input            tag_write_dirty,
  output   [17:0]  tag_read_tag,
  output           tag_read_valid,
  output           tag_read_dirty
);
  reg [17:0] tag_mem_tag   [0:1023];
  reg        tag_mem_valid [0:1023];
  reg        tag_mem_dirty [0:1023];
  integer i;

  initial begin
    for (i = 0; i < 1024; i = i + 1) begin
      tag_mem_tag[i]   = 18'b0;
      tag_mem_valid[i] = 1'b0;
      tag_mem_dirty[i] = 1'b0;
    end
  end

  assign tag_read_tag   = tag_mem_tag[tag_index];
  assign tag_read_valid = tag_mem_valid[tag_index];
  assign tag_read_dirty = tag_mem_dirty[tag_index];

  always @(posedge clk) begin
    if (tag_we) begin
      tag_mem_tag[tag_index]   <= tag_write_tag;
      tag_mem_valid[tag_index] <= tag_write_valid;
      tag_mem_dirty[tag_index] <= tag_write_dirty;
    end
  end
endmodule


module dm_cache_fsm_v (
  input              clk,
  input              rst,
  input      [31:0]  cpu_req_addr,
  input      [31:0]  cpu_req_data,
  input              cpu_req_rw,
  input              cpu_req_valid,
  input      [127:0] mem_data_data,
  input              mem_data_ready,
  output reg [31:0]  mem_req_addr,
  output reg [127:0] mem_req_data,
  output reg         mem_req_rw,
  output reg         mem_req_valid,
  output reg [31:0]  cpu_res_data,
  output reg         cpu_res_ready
);
  localparam [1:0] IDLE        = 2'b00;
  localparam [1:0] COMPARE_TAG = 2'b01;
  localparam [1:0] ALLOCATE    = 2'b10;
  localparam [1:0] WRITE_BACK  = 2'b11;

  reg [1:0] rstate, vstate;

  reg        tag_we;
  reg [9:0]  tag_index;
  reg [17:0] tag_write_tag;
  reg        tag_write_valid;
  reg        tag_write_dirty;
  wire [17:0] tag_read_tag;
  wire        tag_read_valid;
  wire        tag_read_dirty;

  reg        data_we;
  reg [9:0]  data_index;
  reg [127:0] data_write;
  wire [127:0] data_read;

  dm_cache_tag_v ctag (
    .clk(clk),
    .tag_we(tag_we),
    .tag_index(tag_index),
    .tag_write_tag(tag_write_tag),
    .tag_write_valid(tag_write_valid),
    .tag_write_dirty(tag_write_dirty),
    .tag_read_tag(tag_read_tag),
    .tag_read_valid(tag_read_valid),
    .tag_read_dirty(tag_read_dirty)
  );

  dm_cache_data_v cdata (
    .clk(clk),
    .data_we(data_we),
    .data_index(data_index),
    .data_write(data_write),
    .data_read(data_read)
  );

  always @(*) begin
    vstate = rstate;

    tag_we          = 1'b0;
    tag_index       = cpu_req_addr[13:4];
    tag_write_tag   = 18'b0;
    tag_write_valid = 1'b0;
    tag_write_dirty = 1'b0;

    data_we         = 1'b0;
    data_index      = cpu_req_addr[13:4];
    data_write      = data_read;

    mem_req_addr    = cpu_req_addr;
    mem_req_data    = data_read;
    mem_req_rw      = 1'b0;
    mem_req_valid   = 1'b0;

    cpu_res_data    = 32'b0;
    cpu_res_ready   = 1'b0;

    case (cpu_req_addr[3:2])
      2'b00: data_write[31:0]   = cpu_req_data;
      2'b01: data_write[63:32]  = cpu_req_data;
      2'b10: data_write[95:64]  = cpu_req_data;
      2'b11: data_write[127:96] = cpu_req_data;
      default: data_write[31:0] = cpu_req_data;
    endcase

    case (cpu_req_addr[3:2])
      2'b00: cpu_res_data = data_read[31:0];
      2'b01: cpu_res_data = data_read[63:32];
      2'b10: cpu_res_data = data_read[95:64];
      2'b11: cpu_res_data = data_read[127:96];
      default: cpu_res_data = data_read[31:0];
    endcase

    case (rstate)
      IDLE: begin
        if (cpu_req_valid) begin
          vstate = COMPARE_TAG;
        end
      end

      COMPARE_TAG: begin
        if ((cpu_req_addr[31:14] == tag_read_tag) && tag_read_valid) begin
          cpu_res_ready = 1'b1;
          if (cpu_req_rw) begin
            tag_we          = 1'b1;
            data_we         = 1'b1;
            tag_write_tag   = tag_read_tag;
            tag_write_valid = 1'b1;
            tag_write_dirty = 1'b1;
          end
          vstate = IDLE;
        end else begin
          tag_we          = 1'b1;
          tag_write_tag   = cpu_req_addr[31:14];
          tag_write_valid = 1'b1;
          tag_write_dirty = cpu_req_rw;

          mem_req_valid = 1'b1;
          if ((tag_read_valid == 1'b0) || (tag_read_dirty == 1'b0)) begin
            mem_req_rw = 1'b0;
            vstate     = ALLOCATE;
          end else begin
            mem_req_rw = 1'b1;
            vstate     = WRITE_BACK;
          end
        end
      end

      ALLOCATE: begin
        if (mem_data_ready) begin
          data_write = mem_data_data;
          data_we    = 1'b1;
          vstate     = COMPARE_TAG;
        end else begin
          mem_req_valid = 1'b1;
          mem_req_rw    = 1'b0;
        end
      end

      WRITE_BACK: begin
        if (mem_data_ready) begin
          mem_req_valid = 1'b1;
          mem_req_rw    = 1'b0;
          vstate        = ALLOCATE;
        end else begin
          mem_req_valid = 1'b1;
          mem_req_rw    = 1'b1;
        end
      end

      default: begin
        vstate = IDLE;
      end
    endcase
  end

  always @(posedge clk) begin
    if (rst) begin
      rstate <= IDLE;
    end else begin
      rstate <= vstate;
    end
  end
endmodule

