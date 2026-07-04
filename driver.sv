class driver;
transaction tr;
mailbox #(transaction) g2d;
virtual interface_axi inter;
function new(input mailbox #(transaction) g2d,virtual interface_axi inter);
this.g2d=g2d;
this.inter=inter;
endfunction
task run();
tr=new();
forever begin
wait (inter.rst==0);
g2d.get(tr);
tr.display("from driver");
inter.start=tr.start;
inter.T_AWADD=tr.T_AWADD;
inter.T_WDATA=tr.T_WDATA;
inter.T_AWBURST=tr.T_AWBURST;
inter.T_AWLEN=tr.T_AWLEN;
inter.T_AWSIZE=tr.T_AWSIZE;
inter.T_ARADD=tr.T_ARADD;
inter.T_ARBURST=tr.T_ARBURST;
inter.T_ARLEN=tr.T_ARLEN;
inter.T_ARSIZE=tr.T_ARSIZE;
$display("-----------------------AWADD:%d,WDATA:%d,ARADD:%d--------------------",inter.T_AWADD,inter.T_WDATA,inter.T_ARADD);
end
endtask
endclass




