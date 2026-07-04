class scoreboard;

transaction tr1,tr2;

mailbox #(transaction) o2s;
mailbox #(transaction) i2s;

function new(input mailbox #(transaction) o2s,mailbox #(transaction) i2s);
  this.o2s = o2s;
  this.i2s = i2s;
endfunction
task run();
  forever begin
    i2s.get(tr1);
    o2s.get(tr2);

    $display("FROM INPUTMONITOR OF SCOREBOARD = %0d", tr1.T_RDATA);
    $display("FROM OUTPUTMONITOR OF SCORE BOARD = %0d", tr2.T_RDATA);

    if(tr1.T_RDATA == tr2.T_RDATA)
      $display("---------------------------------PASS-----------------------------");
    else
      $display("-----------------------------FAIL---------------------------------");
  end
endtask

endclass

