interface interface_axi(input clk,rst);
logic start;

  logic [31:0] T_AWADD;
  logic [31:0] T_WDATA;
  logic [3:0]  T_AWLEN;
  logic [2:0]  T_AWSIZE;
  logic [1:0]  T_AWBURST;

  logic [31:0] T_ARADD;
  logic [3:0]  T_ARLEN;
  logic [2:0]  T_ARSIZE;
  logic [1:0]  T_ARBURST;
  logic [31:0] T_RDATA;
  endinterface

