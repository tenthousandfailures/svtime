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
   // import "DPI-C" pure function void svtime_example(inout struct_time s1);
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

   static function void sleep(int unsigned t=0);
      c_sleep(t);
      return;
   endfunction // sleep

   // consider default to x to behave the same
   static function struct_time localtime(longint t = -1);
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

   function void now();
      tm = localtime();
   endfunction

   function int mday();
      return(tm.tm_mday);
   endfunction

   function int min();
      return(tm.tm_min);
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
   endfunction // is_dst

   // "%Y-%m-%d %H:%M:%S"
   function string to_s(string fmt = "%m");
      return(strftime(fmt));
   endfunction

   function string strftime(string fmt = "%m");
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
   svtime svtime_inst;
   longint        epocsec;
   string         buffer;

   initial begin

      svtime_inst = new();
      svtimep_inst = new();
      svtimep_inst.now();
      $display("\tsvtimep_inst.to_s: %s", svtimep_inst.to_s());
      buffer = "%M";
      $display("\tsvtimep_inst.to_s: %s", svtimep_inst.to_s("%M"));
      svtime::sleep(2);
      svtimep_inst.now();
      $display("\tsvtimep_inst.to_s: %s", svtimep_inst.to_s());

      $display("PASS asctime");
      s1 = svtime::localtime();
      $display("s1.tm_sec: %0d", s1.tm_sec);
      $display("s1.tm_min: %0d", s1.tm_min);

      $display("svtime_inst   asctime: %s", svtime::asctime(s1));

      s1 = svtime::localtime();
      s1.tm_year = 81;
      $display("svtime_inst   asctime: %s", svtime::asctime(s1));

      $display("PASS mktime");
		  s1.tm_sec = 1;
		  s1.tm_year = 117;
		  $display("SV: s1.tm_sec=%0d,s1.tm_year=%0d",s1.tm_sec,s1.tm_year);
      $display("svtime_inst.mktime(s1): %0d", svtime::mktime(s1));
      $display("ctime of mktime: %s", svtime::ctime(svtime::mktime(s1)));
      epocsec = svtime::mktime(s1);

      $display("PASS sv_time");
      $display("sv_time: %0d", svtime::sv_time());

      $display("PASS strftime");
      $display("svtime_inst   strftime: %s\n", svtime::strftime(32, "%M %M",s1, buffer));

      $display("\nPASS sleep");
      s1 = svtime::localtime();
      $display("svtime_inst   asctime: %s", svtime::asctime(s1));
      svtime::sleep(2);
      s1 = svtime::localtime();
      $display("svtime_inst   asctime: %s", svtime::asctime(s1));

      $display("PASS ctime");
      $display("ctime: %s", svtime::ctime());
      $display("ctime(%0d): %s", epocsec, svtime::ctime(epocsec));

      $finish();
   end

endprogram : top
