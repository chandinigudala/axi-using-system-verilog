program tb(interface_axi inter);
test t;
initial begin
t=new(inter);
t.run();
end
endprogram
