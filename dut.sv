module top1 (
  input clk,
  input rst,
  input start,

  input [31:0] T_AWADD,
  input [31:0] T_WDATA,
  input [3:0]  T_AWLEN,
  input [2:0]  T_AWSIZE,
  input [1:0]  T_AWBURST,

  input [31:0] T_ARADD,
  input [3:0]  T_ARLEN,
  input [2:0]  T_ARSIZE,
  input [1:0]  T_ARBURST,

  output [31:0] T_RDATA    
);

  wire [31:0] AWADD, WDATA, ARADD, RDATA;
  wire [3:0]  AWLEN, ARLEN;
  wire [2:0]  AWSIZE, ARSIZE;
  wire [1:0]  AWBURST, ARBURST;
  wire AWVALID, AWREADY, WVALID, WREADY;
  wire BVALID, BREADY, ARVALID, ARREADY;
  wire RVALID, RREADY;

  master m (.*);
  slave  s (.*);

  
  assign T_RDATA = RDATA;

endmodule
module master (
  input clk,
  input rst,
  input start,

  // write inputs
  input [31:0] T_AWADD,
  input [31:0] T_WDATA,
  input [3:0]  T_AWLEN,
  input [2:0]  T_AWSIZE,
  input [1:0]  T_AWBURST,

  // read inputs
  input [31:0] T_ARADD,
  input [3:0]  T_ARLEN,
  input [2:0]  T_ARSIZE,
  input [1:0]  T_ARBURST,

  // WRITE ADDRESS
  output reg [31:0] AWADD,
  output reg [3:0]  AWLEN,
  output reg [2:0]  AWSIZE,
  output reg [1:0]  AWBURST,
  output reg        AWVALID,
  input             AWREADY,

  // WRITE DATA
  output reg [31:0] WDATA,
  output reg        WVALID,
  input             WREADY,

  // WRITE RESPONSE
  input             BVALID,
  output reg        BREADY,

  // READ ADDRESS
  output reg [31:0] ARADD,
  output reg [3:0]  ARLEN,
  output reg [2:0]  ARSIZE,
  output reg [1:0]  ARBURST,
  output reg        ARVALID,
  input             ARREADY,

  // READ DATA
  input  [31:0] RDATA,
  input         RVALID,
  output reg    RREADY
);

  reg [3:0] wcnt, rcnt;
  reg write_active, read_active;

  reg [4:0] total_beats_w, total_beats_r;
  reg [31:0] beat_bytes_w, beat_bytes_r;

  always @(posedge clk) begin
    if (rst) begin
      AWVALID <= 0; WVALID <= 0; BREADY <= 0;
      ARVALID <= 0; RREADY <= 0;
      write_active <= 0; read_active <= 0;
      wcnt <= 0; rcnt <= 0;
    end else begin

      // ---------------- START WRITE ----------------
      if (start && !write_active) begin
        write_active <= 1;
        wcnt <= 0;

        AWADD   <= T_AWADD;
        AWLEN   <= T_AWLEN;
        AWSIZE  <= T_AWSIZE;
        AWBURST <= T_AWBURST;

        total_beats_w <= T_AWLEN + 1;
        beat_bytes_w  <= (1 << T_AWSIZE);

        AWVALID <= 1;
      end

      if (AWVALID && AWREADY)
        AWVALID <= 0;

      // ---------------- WRITE DATA ----------------
      if (write_active && !WVALID && wcnt < total_beats_w) begin
        WVALID <= 1;
        WDATA  <= T_WDATA + wcnt;
      end

      if (WVALID && WREADY) begin
        WVALID <= 0;
        if (wcnt == total_beats_w - 1)
          BREADY <= 1;
        wcnt <= wcnt + 1;
      end

      // ---------------- WRITE RESPONSE ----------------
      if (BVALID && BREADY) begin
        BREADY <= 0;
        write_active <= 0;

        // START READ
        read_active <= 1;
        rcnt <= 0;

        ARADD   <= T_ARADD;
        ARLEN   <= T_ARLEN;
        ARSIZE  <= T_ARSIZE;
        ARBURST <= T_ARBURST;

        total_beats_r <= T_ARLEN + 1;
        beat_bytes_r  <= (1 << T_ARSIZE);

        ARVALID <= 1;
      end

      if (ARVALID && ARREADY)
        ARVALID <= 0;

      // ---------------- READ DATA ----------------
      if (read_active) begin
        RREADY <= 1;

        if (RVALID && RREADY) begin
          if (rcnt == total_beats_r - 1) begin
            RREADY <= 0;
            read_active <= 0;
          end
          rcnt <= rcnt + 1;
        end
      end
    end
  end
endmodule
module slave (
  input clk,
  input rst,

  // WRITE ADDRESS
  input [31:0] AWADD,
  input [3:0]  AWLEN,
  input [2:0]  AWSIZE,
  input [1:0]  AWBURST,
  input        AWVALID,
  output       AWREADY,

  // WRITE DATA
  input [31:0] WDATA,
  input        WVALID,
  output       WREADY,

  // WRITE RESPONSE
  output reg   BVALID,
  input        BREADY,

  // READ ADDRESS
  input [31:0] ARADD,
  input [3:0]  ARLEN,
  input [2:0]  ARSIZE,
  input [1:0]  ARBURST,
  input        ARVALID,
  output       ARREADY,

  // READ DATA
  output reg [31:0] RDATA,
  output reg        RVALID,
  input             RREADY
);

  reg [31:0] mem [0:15];
  reg [31:0] waddr, raddr;
  reg [3:0]  wcnt, rcnt;

  reg [31:0] beat_bytes_w, beat_bytes_r;
  reg [4:0] total_beats_w, total_beats_r;

  assign AWREADY = 1;
  assign WREADY  = 1;
  assign ARREADY = 1;

  always @(posedge clk) begin
    if (rst) begin
      BVALID <= 0;
      RVALID <= 0;
    end else begin

      // ---------------- WRITE ADDRESS ----------------
      if (AWVALID) begin
        waddr <= AWADD;
        wcnt <= 0;
        total_beats_w <= AWLEN + 1;
        beat_bytes_w  <= (1 << AWSIZE);
      end

      // ---------------- WRITE DATA ----------------
      if (WVALID && !BVALID) begin
        mem[waddr] <= WDATA;
        waddr <= waddr + beat_bytes_w;
        wcnt <= wcnt + 1;

        if (wcnt == total_beats_w - 1)
          BVALID <= 1;
      end

      if (BVALID && BREADY)
        BVALID <= 0;

      // ---------------- READ ADDRESS ----------------
      if (ARVALID) begin
        raddr <= ARADD;
        rcnt <= 0;
        total_beats_r <= ARLEN + 1;
        beat_bytes_r  <= (1 << ARSIZE);
      end

      // ---------------- READ DATA ----------------
      if (!RVALID && rcnt < total_beats_r) begin
        RDATA <= mem[raddr];
        RVALID <= 1;
      end

      if (RVALID && RREADY) begin
        RVALID <= 0;
        raddr <= raddr + beat_bytes_r;
        rcnt <= rcnt + 1;
      end
    end
  end
endmodule

