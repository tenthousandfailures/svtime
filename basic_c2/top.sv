package svtime_pkg;

   // this struct matches the c one
   typedef struct {
      int         tm_sec;
      int         tm_min;
      int         tm_hour;
      int         tm_mday;
      int         tm_mon;
      int         tm_year;
      int         tm_wday;
      int         tm_yday;
      int         tm_isdst;
   } struct_time;

   // note best to use pure below
   import "DPI-C" pure function string c_ctime(input longint t);
   import "DPI-C" pure function longint c_time();
   import "DPI-C" pure function void c_localtime(input longint t, inout struct_time tm);
   import "DPI-C" pure function string c_asctime(input struct_time tm);
   import "DPI-C" pure function longint c_mktime(input struct_time tm);
   import "DPI-C" pure function void c_sleep(input int unsigned t);
   import "DPI-C" pure function string c_strftime(input int bsize, input string fmt, input struct_time tm, inout string target);

class svtime;

   // having these as static functions allows them to be called without inst
   static function string ctime(longint t = 0);
      return(c_ctime(t));
   endfunction

   // passing the buffer string to the function seems to fix a corruption issue
   // when passing the string pointer back it seemed as if c was flushing the results
   static function string strftime(int bsize = 80, string fmt, ref struct_time st, string buffer);
      return(c_strftime(bsize, fmt, st, buffer));
   endfunction

   // NOTE "time" is a SV keyword so have to prefix function with sv
   static function longint sv_time();
      return(c_time());
   endfunction // svtime_time

   static function longint mktime(ref struct_time st);
      return(c_mktime(st));
   endfunction // svtime_time

   static function void sleep(int unsigned t = 0);
      c_sleep(t);
      return;
   endfunction // sleep

   // consider default to x to behave the same
   static function struct_time localtime(longint t = 0);
      struct_time x;
      c_localtime(t, x);
      return x;
   endfunction // localtime

   static function string asctime(ref struct_time st);
      return (c_asctime(st));
   endfunction // asctime

   function new();
   endfunction // new

endclass // svtime

class svtimep extends svtime;
   struct_time tm;

   function new(integer year = 'x,
                integer mon = 1,
                integer mday = 1,
                integer hour = 0,
                integer min = 0,
                integer sec = 0);
      if ($isunknown(year)) begin
         tm = localtime();
      end else begin
         tm.tm_year = year;
         tm.tm_mon = mon;
         tm.tm_mday = mday;
         tm.tm_hour = hour;
         tm.tm_min = min;
         tm.tm_sec = sec;
      end
   endfunction // new

   function void now(longint t = 0);
      if (t == 0) begin
         tm = localtime();
      end else begin
         tm = super.localtime(t);
      end
   endfunction

   function int sec();
      return(tm.tm_sec);
   endfunction

   function int min();
      return(tm.tm_min);
   endfunction

   function int mday();
      return(tm.tm_mday);
   endfunction

   function int mon();
      return(tm.tm_mon);
   endfunction

   function int month();
      return(tm.tm_mon);
   endfunction

   function int year();
      return(tm.tm_year);
   endfunction // year

   function int to_i();
      return super.mktime(tm);
   endfunction

   function bit is_dst();
      if (tm.tm_isdst == 1) begin
         return(1);
      end else begin
         return(0);
      end
   endfunction

   function string to_s(string fmt = "%Y-%m-%d %H:%M:%S");
      return(strftime(fmt));
   endfunction

   function string strftime(string fmt = "%Y-%m-%d %H:%M:%S");
      string target;
      target = super.strftime(100, fmt, tm, target);
      return(target);
   endfunction

endclass

endpackage // svtime_pkg

program top;

   import svtime_pkg::*;

   struct_time s1;
   svtimep svtimep_inst;

   longint        epocsec;
   string         buffer;

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

            $finish();
         end
      end
   end

endprogram : top
