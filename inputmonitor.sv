class inputmonitor;

transaction tr;
mailbox #(transaction) i2s;
virtual interface_axi inter;

// ---------------- INTERNAL VARIABLES ----------------
bit [3:0] wcnt, rcnt;
bit write_active, read_active;

bit [4:0] total_beats_w, total_beats_r;
bit [31:0] beat_bytes_w, beat_bytes_r;

bit [31:0] mem [0:15];
bit [31:0] waddr, raddr;

// AXI SIGNAL STORAGE (local)
bit [31:0] AWADD, WDATA, ARADD;
bit [3:0]  AWLEN, ARLEN;
bit [2:0]  AWSIZE, ARSIZE;
bit [1:0]  AWBURST, ARBURST;

bit AWVALID, WVALID, BREADY, ARVALID, RREADY;
bit AWREADY, WREADY, ARREADY;
bit BVALID, RVALID;
bit [31:0] RDATA;

function new(input mailbox #(transaction) i2s,
             virtual interface_axi inter);
  this.i2s = i2s;
  this.inter = inter;
endfunction

// ---------------- RUN TASK ----------------
task run();
  forever begin
    @(posedge inter.clk);

    tr = new();   // VERY IMPORTANT (new object every cycle)

    tr.clk       = inter.clk;
    tr.rst       = inter.rst;
    tr.start     = inter.start;
    tr.T_AWADD   = inter.T_AWADD;
    tr.T_WDATA   = inter.T_WDATA;
    tr.T_AWLEN   = inter.T_AWLEN;
    tr.T_AWSIZE  = inter.T_AWSIZE;
    tr.T_AWBURST = inter.T_AWBURST;
    tr.T_ARADD   = inter.T_ARADD;
    tr.T_RDATA   = inter.T_RDATA;   // ⭐ MOST IMPORTANT LINE

    if(inter.T_RDATA !== 0) begin
      $display("BFM DATA = %0d", inter.T_RDATA);
      tr.display("from inputmonitor");
      i2s.put(tr);
    end
  end
endtask


// ---------------- BFM ----------------
task bfm();
  fork
    bfm_master();
    bfm_slave();
  join_none
endtask

// ---------------- MASTER ----------------
task bfm_master();
  forever begin
    @(posedge inter.clk);

    if (inter.rst) begin
      AWVALID = 0; WVALID = 0; BREADY = 0;
      ARVALID = 0; RREADY = 0;
      write_active = 0; read_active = 0;
      wcnt = 0; rcnt = 0;
    end
    else begin

      if (inter.start && !write_active) begin
        write_active = 1;
        wcnt = 0;

        AWADD   = inter.T_AWADD;
        AWLEN   = inter.T_AWLEN;
        AWSIZE  = inter.T_AWSIZE;
        AWBURST = inter.T_AWBURST;

        total_beats_w = inter.T_AWLEN + 1;
        beat_bytes_w  = (1 << inter.T_AWSIZE);

        AWVALID = 1;
      end

      if (AWVALID && AWREADY)
        AWVALID = 0;

      if (write_active && !WVALID && wcnt < total_beats_w) begin
        WVALID = 1;
        WDATA  = inter.T_WDATA + wcnt;
      end

      if (WVALID && WREADY) begin
        WVALID = 0;
        if (wcnt == total_beats_w - 1)
          BREADY = 1;
        wcnt++;
      end

      if (BVALID && BREADY) begin
        BREADY = 0;
        write_active = 0;

        read_active = 1;
        rcnt = 0;

        ARADD   = inter.T_ARADD;
        ARLEN   = inter.T_ARLEN;
        ARSIZE  = inter.T_ARSIZE;
        ARBURST = inter.T_ARBURST;

        total_beats_r = inter.T_ARLEN + 1;
        beat_bytes_r  = (1 << inter.T_ARSIZE);

        ARVALID = 1;
      end

      if (ARVALID && ARREADY)
        ARVALID = 0;

      if (read_active) begin
        RREADY = 1;

        if (RVALID && RREADY) begin
          if (rcnt == total_beats_r - 1) begin
            RREADY = 0;
            read_active = 0;
          end
          rcnt++;
        end
      end
    end
  end
endtask

// ---------------- SLAVE ----------------
task bfm_slave();
  AWREADY = 1;
  WREADY  = 1;
  ARREADY = 1;

  forever begin
    @(posedge inter.clk);

    if (inter.rst) begin
      BVALID = 0;
      RVALID = 0;
    end
    else begin

      if (AWVALID) begin
        waddr = AWADD;
        wcnt = 0;
        total_beats_w = AWLEN + 1;
        beat_bytes_w  = (1 << AWSIZE);
      end

      if (WVALID && !BVALID) begin
        mem[waddr] = WDATA;
        waddr = waddr + beat_bytes_w;
        wcnt++;

        if (wcnt == total_beats_w - 1)
          BVALID = 1;
      end

      if (BVALID && BREADY)
        BVALID = 0;

      if (ARVALID) begin
        raddr = ARADD;
        rcnt = 0;
        total_beats_r = ARLEN + 1;
        beat_bytes_r  = (1 << ARSIZE);
      end

      if (!RVALID && rcnt < total_beats_r) begin
        RDATA = mem[raddr];
        RVALID = 1;
      end

      if (RVALID && RREADY) begin
        RVALID = 0;
        raddr = raddr + beat_bytes_r;
        rcnt++;
      end
    end
  end
endtask

endclass

