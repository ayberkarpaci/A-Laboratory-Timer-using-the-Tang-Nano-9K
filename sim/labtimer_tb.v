// Self-checking testbench for labtimer.v.
// Run: iverilog -o sim/labtimer_tb sim/labtimer_tb.v labtimer.v && vvp sim/labtimer_tb
`timescale 1ns/1ps

module labtimer_tb;
  reg CLK = 0, SW = 1, B3 = 0, B2 = 0, B1 = 0, B0 = 0, HZ1 = 0;
  wire [3:0] M10, M1, S10, S1;
  integer errors = 0;

  labtimer dut (.CLK(CLK), .SW(SW), .B3(B3), .B2(B2), .B1(B1), .B0(B0),
                .HZ1(HZ1), .M10(M10), .M1(M1), .S10(S10), .S1(S1));

  always #5 CLK = ~CLK;

  // One button press: held for a few clock cycles, then released.
  task press(input integer digit);
    begin
      case (digit)
        3: B3 = 1; 2: B2 = 1; 1: B1 = 1; 0: B0 = 1;
      endcase
      repeat (3) @(posedge CLK);
      {B3, B2, B1, B0} = 4'b0;
      repeat (3) @(posedge CLK);
    end
  endtask

  // One period of the 1 Hz time base, compressed to a few clock cycles.
  task tick(input integer n);
    integer i;
    begin
      for (i = 0; i < n; i = i + 1) begin
        HZ1 = 1; repeat (3) @(posedge CLK);
        HZ1 = 0; repeat (3) @(posedge CLK);
      end
    end
  endtask

  task set_mode(input s);
    begin
      SW = s; repeat (3) @(posedge CLK);
    end
  endtask

  task expect_time(input [3:0] m10, m1, s10, s1, input [8*40-1:0] what);
    begin
      if ({M10, M1, S10, S1} !== {m10, m1, s10, s1}) begin
        $display("FAIL %0s: got %0d%0d:%0d%0d, expected %0d%0d:%0d%0d",
                 what, M10, M1, S10, S1, m10, m1, s10, s1);
        errors = errors + 1;
      end else
        $display("ok   %0s: %0d%0d:%0d%0d", what, M10, M1, S10, S1);
    end
  endtask

  integer i;
  initial begin
    repeat (3) @(posedge CLK);
    expect_time(0, 0, 0, 0, "power-on");

    // Set mode: every digit increments on its own button and wraps.
    press(0); press(0); press(0);
    expect_time(0, 0, 0, 3, "set S1 to 3");
    for (i = 0; i < 6; i = i + 1) press(1);
    expect_time(0, 0, 0, 3, "S10 wraps after 5");
    for (i = 0; i < 10; i = i + 1) press(2);
    expect_time(0, 0, 0, 3, "M1 wraps after 9");
    press(3);
    expect_time(1, 0, 0, 3, "set M10 to 1");
    for (i = 0; i < 9; i = i + 1) press(3);
    expect_time(0, 0, 0, 3, "M10 wraps after 9");

    // Run mode: count down to 00:00, then count up (overtime).
    set_mode(0);
    tick(2);
    expect_time(0, 0, 0, 1, "count down");
    tick(1);
    expect_time(0, 0, 0, 0, "reach zero");
    tick(2);
    expect_time(0, 0, 0, 2, "overtime counts up");

    // Buttons are ignored while running.
    press(0);
    expect_time(0, 0, 0, 2, "buttons ignored in run mode");

    // Back to set mode, adjust, and run again: must count DOWN again.
    set_mode(1);
    press(0);
    expect_time(0, 0, 0, 3, "adjust after overtime");
    set_mode(0);
    tick(1);
    expect_time(0, 0, 0, 2, "second run counts down");

    // Borrow across all digits: 10:00 -> 09:59.
    set_mode(1);
    press(0); press(0); press(0); press(0); press(0); press(0); press(0); press(0);
    press(3);
    expect_time(1, 0, 0, 0, "set 10:00");
    set_mode(0);
    tick(1);
    expect_time(0, 9, 5, 9, "borrow 10:00 -> 09:59");

    // Carry across digits in overtime: 00:59 -> 01:00.
    set_mode(1);
    press(2);                                  // M1 wraps 9 -> 0
    expect_time(0, 0, 5, 9, "set 00:59");
    set_mode(0);
    tick(59);
    expect_time(0, 0, 0, 0, "count down to zero");
    tick(59);
    expect_time(0, 0, 5, 9, "overtime 00:59");
    tick(1);
    expect_time(0, 1, 0, 0, "carry 00:59 -> 01:00");

    if (errors == 0) begin
      $display("PASS: all checks passed");
      $finish;
    end else begin
      $display("FAILED: %0d check(s)", errors);
      $fatal(1);
    end
  end
endmodule
