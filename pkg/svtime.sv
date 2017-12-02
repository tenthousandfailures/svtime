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

   function int hour();
      return(tm.tm_hour);
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

   function longint to_i();
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

// interface that can be customized to keep track relation of input clk to wall-time
interface time_monitor(input reg clk);
   parameter period = 2;
   parameter prefix = "tm";

   longint   cycles = 0;
   svtime_pkg::svtimep svtimep_inst;

   // initialize the svtimep class
   initial begin
      svtimep_inst = new();
      svtimep_inst.now();
      $display("[%s] time_monitor at simtime %0t initial with period %0d at epoc sec: %0d", prefix, $time(), period, svtimep_inst.to_i());
   end

   always @(posedge clk) begin;
      if (cycles >= period) begin
         svtimep_inst.now();
         $display("[%s] time_monitor at simtime %0t with period %0d at epoc sec: %0d", prefix, $time(), period, svtimep_inst.to_i());
         cycles = 0;
      end else begin
         cycles++;
      end
   end
endinterface

interface time_alarmclock(input reg clk);
   parameter period = 2;
   parameter alarm_hour = 5;
   parameter alarm_min  = 0;
   parameter prefix = "ta";

   bit triggered = 0;
   svtime_pkg::svtimep svtimep_inst;

   // initialize the svtimep class
   initial begin
      svtimep_inst = new();
      svtimep_inst.now();
      $display("[%s] time_alarmclock at simtime %0t initial with period %0d at %2d:%2d:%2d", prefix, $time(), period, svtimep_inst.hour(), svtimep_inst.min(), svtimep_inst.sec());
   end

   // trigger if walltime equals alarm_hour and at or above alarm_min
   always @(posedge clk) begin;
      svtimep_inst.now();
      if (
          (triggered == 0) &&
          (alarm_hour == svtimep_inst.hour()) &&
          (alarm_min <= svtimep_inst.min())
         ) begin
         $display("[%s] time_alarmclock TRIGGERED at simtime %0t with period %0d at %2d:%2d:%2d", prefix, $time(), period, svtimep_inst.hour(), svtimep_inst.min(), svtimep_inst.sec());
         triggered = 1;
      end else begin
         // $display("[%s] time_alarmclock NOT TRIGGERED at simtime %0t with period %0d at %2d:%2d:%2d", prefix, $time(), period, svtimep_inst.hour(), svtimep_inst.min(), svtimep_inst.sec());
      end
   end
endinterface
