program top;
   // note best to use pure below
   import "DPI-C" pure function void print_hello();
   import "DPI-C" pure function int  simple_add(int a, int b);
   import "DPI-C" pure function void simple_time();
   import "DPI-C" pure function longint  simple_time_seconds();

   int dummy;

   // the time in seconds is a 64 bit longint value
   longint dummy2, dummy3;

   string a;         // return code of system command

   // integer is 4 state logic while int is 2 - for time it is better to use int
   int date_file;    // file handle
   int date_rc;      //

   string  date_str; // date in string format
   int date_int;     // date in int (seconds) format

   initial begin

      // most basic dpi call to stdout
      print_hello();

      // passing in args
      dummy = simple_add(1,2);
      $display("dummy %d", dummy);

      // simple dpi call to time
      simple_time();

      // getting return value from time
      dummy2 = simple_time_seconds();
      $display("simple_time_seconds dummy2 %d", dummy2);
      a = $system("sleep 3");
      dummy3 = simple_time_seconds();
      $display("simple_time_seconds dummy3 %d", dummy3);

      // finish
      $finish();
   end

endprogram : top
