class transaction;
bit  clk;
bit rst;
bit start;

 bit  [31:0] T_AWADD;
 bit [31:0] T_WDATA;
 bit [3:0]  T_AWLEN;
 bit [2:0]  T_AWSIZE;
 bit [1:0]  T_AWBURST;

 bit [31:0] T_ARADD;
 bit [3:0]  T_ARLEN;
 bit [2:0]  T_ARSIZE;
 bit [1:0]  T_ARBURST;
 bit [31:0] T_RDATA;
 function void display(string s="from transaction");
 $display(" %s clk:%b,rst:%b,start:%b,AWADD:%d,WDATA:%d,AWLEN:%d,AWSIZE:%d,AWBURST:%d,ARADD:%d,RDATA:%d",s,clk,rst,start,T_AWADD,T_WDATA,T_AWLEN,T_AWSIZE,T_AWBURST,T_ARADD,T_RDATA);
 endfunction
 endclass

