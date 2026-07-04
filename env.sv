class env;
transaction tr;
generator gr;
driver dr;
inputmonitor im;
outputmonitor om;
scoreboard sc;
mailbox #(transaction) i2s,o2s,g2d;
virtual interface_axi inter;
function new(input virtual interface_axi inter);
this.inter=inter;
endfunction
task build();
g2d=new();
i2s=new();
o2s=new();
tr=new();
gr=new(g2d);
dr=new(g2d,inter);
im=new(i2s,inter);
om=new(o2s,inter);
sc=new(o2s,i2s);
endtask
task run();
build();
fork
gr.run();
dr.run();
im.run();
om.run();
sc.run();
join
endtask
endclass

