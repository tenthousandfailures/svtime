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

class svtime;

   struct_time st;

   function string svtime_ctime(longint t = -1);
      return(c_ctime(t));
   endfunction

   function longint svtime_time();
      return(c_time());
   endfunction // svtime_time

   function void svtime_localtime(longint t = -1, ref struct_time st = this.st);
      c_localtime(t, st);
   endfunction // svtime_localtime

   function string svtime_asctime(ref struct_time st = this.st);
      return (c_asctime(st));
   endfunction // svtime_asctime

   function new();
   endfunction // new

endclass
endpackage // svtime_pkg

program top;

   import svtime_pkg::*;

   // note best to use pure below
   import "DPI-C" pure function void svtime_example(inout struct_time s1);

   struct_time s1;
   svtime svtime_inst;

   initial begin

      svtime_inst = new();
      $display("svtime_inst     ctime: %s", svtime_inst.svtime_ctime());
      $display("svtime_inst      time: %0d", svtime_inst.svtime_time());

      svtime_inst.st.tm_sec = 59;
      svtime_inst.svtime_localtime();
      $display("svtime_inst.st.tm_sec: %0d", svtime_inst.st.tm_sec);
      $display("svtime_inst.st.tm_min: %0d", svtime_inst.st.tm_min);

      $display("svtime_inst   asctime: %s", svtime_inst.svtime_asctime());


		  s1.tm_sec =1;
		  s1.tm_min =2;
		  $display("SV: s1.tm_sec=%0d,s1.tm_min=%0d",s1.tm_sec,s1.tm_min);

		  svtime_example(s1);
		  $display("SV after DPI call: s1.tm_sec=%0d,s1.tm_min=%0d",s1.tm_sec,s1.tm_min);

      // finish
      $finish();
   end

endprogram : top
