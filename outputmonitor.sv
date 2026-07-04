class outputmonitor;
transaction tr;
mailbox #(transaction) o2s;
virtual interface_axi inter;
function new(input mailbox #(transaction) o2s, virtual interface_axi inter);
this.o2s=o2s;
this.inter=inter;
endfunction
task run();
  forever begin
    @(posedge inter.clk);

    if(inter.T_RDATA !== 0) begin
      tr = new();
      tr.T_RDATA = inter.T_RDATA;

      $display("from OUTPUT MONITOR  DATA = %0d", inter.T_RDATA);
      tr.display("from outputmonitor");

      o2s.put(tr);
    end
  end
endtask
endclass

