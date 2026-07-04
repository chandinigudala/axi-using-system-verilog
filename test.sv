class test;
env e;
virtual interface_axi inter;
function new(input virtual interface_axi inter);
this.inter=inter;
endfunction
task run();
e=new(inter);
e.run();
endtask
endclass

