package svtime_pkg;

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

   import "DPI-C" pure function string c_ctime(longint t);
   import "DPI-C" pure function longint c_time();
   import "DPI-C" pure function void c_localtime(longint t, inout struct_time tm);
   import "DPI-C" pure function string c_asctime(inout struct_time tm);
   import "DPI-C" pure function longint c_mktime(inout struct_time tm);

class svtime;

   function string ctime(longint t = 0);
      return(c_ctime(t));
   endfunction

   // NOTE "time" is a SV keyword so have to prefix function with sv_
   function longint sv_time();
      return(c_time());
   endfunction // svtime_time

   function longint mktime(ref struct_time st);
      return(c_mktime(st));
   endfunction // svtime_time

   function struct_time localtime(longint t = -1);
      struct_time x;
      c_localtime(t, x);
      return x;
   endfunction // localtime

   function string asctime(ref struct_time st);
      return (c_asctime(st));
   endfunction // asctime

   function new();
   endfunction // new

endclass
endpackage // svtime_pkg

program top;

   import svtime_pkg::*;

   // note best to use pure below
   // import "DPI-C" pure function void svtime_example(inout struct_time s1);

   struct_time s1;
   svtime svtime_inst;
   longint        epocsec;

   initial begin

      svtime_inst = new();

      $display("PASS asctime");
      s1 = svtime_inst.localtime();
      $display("s1.tm_sec: %0d", s1.tm_sec);
      $display("s1.tm_min: %0d", s1.tm_min);

      $display("svtime_inst   asctime: %s", svtime_inst.asctime(s1));

      s1 = svtime_inst.localtime();
      s1.tm_year = 81;
      $display("svtime_inst   asctime: %s", svtime_inst.asctime(s1));





      $display("PASS mktime");
		  s1.tm_sec = 1;
		  s1.tm_year = 117;
		  $display("SV: s1.tm_sec=%0d,s1.tm_year=%0d",s1.tm_sec,s1.tm_year);
      $display("svtime_inst.mktime(s1): %0d", svtime_inst.mktime(s1));

      $display("ctime of mktime: %s", svtime_inst.ctime(svtime_inst.mktime(s1)));

      epocsec = svtime_inst.mktime(s1);




      $display("PASS sv_time");
      $display("sv_time: %0d", svtime_inst.sv_time());






      $display("PASS ctime");
      $display("ctime: %s", svtime_inst.ctime());
      $display("ctime(%0d): %s", epocsec, svtime_inst.ctime(epocsec));

      $finish();
   end

endprogram : top
