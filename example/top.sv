module top;

   import svtime_pkg::*;

   struct_time s1;
   svtimep svtimep_inst;

   longint        epocsec;
   string         buffer;

   reg            clk = 0;

   // NOTE: uncomment follow ling to show the time_monitor
   time_monitor #(.period(1)) time_monitor_inst(.clk(clk));
   time_alarmclock #(.period(1), .alarm_hour(22)) time_alarmclock_inst(.clk(clk));

   // using python / c style time static functions
   task perf_test1();
      s1 = svtime::localtime();
      epocsec = svtime::mktime(s1);
      // $display(epocsec);
   endtask

   // using ruby style time object
   task perf_test2();
      svtimep_inst.now();
      epocsec = svtimep_inst.to_i();
      // $display(epocsec);
   endtask

   always #1 clk = ~clk;

   initial begin

      string  method;       // string to hold which test to do
      longint loop;         // how many times to loop
      string  a;            // temp string

      if ($value$plusargs("LOOP=%s", a)) begin
         loop = a.atoi();
      end else begin
         loop = 10000000;
      end

      if ($value$plusargs("TESTNAME=%s", method)) begin
         if (method == "PERFORMANCE1") begin
            svtimep_inst = new();
            for (longint i = 0; i < loop; i = i + 1) begin
               perf_test1();
            end
            $finish();
         end else if (method == "PERFORMANCE2") begin
            svtimep_inst = new();
            for (longint i = 0; i < loop; i = i + 1) begin
               perf_test2();
            end
            $finish();
         end else begin

            svtimep_inst = new();
            svtimep_inst.now();
            $display("\n svtimep convenience wrapper:");
            $display("\t svtimep_inst.to_s() = %s", svtimep_inst.to_s());
            $display("\t svtimep_inst.sec() = %d", svtimep_inst.sec());
            $display("\t svtimep_inst.min() = %d", svtimep_inst.min());

            buffer = "%M";
            $display("\t svtimep_inst.to_s(H M S) = %s", svtimep_inst.to_s("%H:%M:%S"));
            svtime::sleep(2);
            svtimep_inst.now();
            $display("\t svtimep_inst.to_s() = %s", svtimep_inst.to_s());
            $display("\t svtimep_inst.to_i() = %0d", svtimep_inst.to_i());

            $display("\n svtime static functions:");
            s1 = svtime::localtime();
            $display("\t svtime::asctime(s1): %s", svtime::asctime(s1));
            $display("\t s1.tm_sec = %0d", s1.tm_sec);
            $display("\t s1.tm_min = %0d", s1.tm_min);
            svtime::sleep(2);
            s1 = svtime::localtime();
            $display("\t svtime::asctime(s1): %s", svtime::asctime(s1));


            $display("\n svtime static functions set year convert back to time:");
            s1 = svtime::localtime();
            s1.tm_year = 81;
            $display("\t svtime::asctime(s1) = %s", svtime::asctime(s1));

            $display("\n svtime static functions set sec and year:");
		        s1.tm_sec = 1;
		        s1.tm_year = 116;
		        $display("\t s1.tm_sec = %0d, s1.tm_year = %0d",s1.tm_sec,s1.tm_year);
            $display("\t svtime::mktime(s1) = %0d", svtime::mktime(s1));
            $display("\t svtime::ctime(svtime::mktime(s1))) = %s", svtime::ctime(svtime::mktime(s1)));
            epocsec = svtime::mktime(s1);

            $display("\n svtime static function strftime:");
            // $display("\t svtime::sv_time = %0d", svtime::sv_time());

            $display("\t svtime::strftime(32, M M,s1, buffer) = %s", svtime::strftime(32, "%M %M",s1, buffer));

            $display("\n svtime static function sleep:");
            s1 = svtime::localtime();
            $display("\t svtime::asctime(s1) = %s", svtime::asctime(s1));
            svtime::sleep(2);
            $display("\t svtime::sleep(2)");
            s1 = svtime::localtime();
            $display("\t svtime::asctime(s1) = %s", svtime::asctime(s1));

            $display("\n svtime static function ctime:");
            $display("\t svtime::ctime() = %s", svtime::ctime());
            $display("\t svtime::ctime(%0d) = %s", epocsec, svtime::ctime(epocsec));

            #10;

            $finish();
         end
      end
   end

endmodule : top
