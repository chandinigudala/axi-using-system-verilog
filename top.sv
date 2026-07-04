`include "dut.sv"
`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "inputmonitor.sv"
`include "outputmonitor.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"
`include "program.sv"
module top();
reg clk,rst;
interface_axi inter(.clk(clk),.rst(rst));
top1 a1(.clk(inter.clk),.rst(inter.rst),.start(inter.start),.T_AWADD(inter.T_AWADD),.T_WDATA(inter.T_WDATA),.T_AWLEN(inter.T_AWLEN),.T_AWSIZE(inter.T_AWSIZE),.T_AWBURST(inter.T_AWBURST),.T_ARADD(inter.T_ARADD),.T_RDATA(inter.T_RDATA),.T_ARLEN(inter.T_ARLEN),.T_ARSIZE(inter.T_ARSIZE),.T_ARBURST(inter.T_ARBURST));
tb a2(inter);
initial begin
clk=0;
rst=1;
#10;
rst=0;
end
always #5 clk=~clk;
initial begin
#250 $finish();
end
endmodule
