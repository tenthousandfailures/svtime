module top;

   string a;             // return code of system command

   integer date_file;    // file handle
   integer date_rc;      // holds return code

   string  date_str;     // date in string format
   integer date_int;     // date in integer (seconds) format

   longint loop;         // how many loops to perform default 100000

   task perf_test();
      // will get the seconds back into date_int
      a = $system("date +%s > t");
      date_file = $fopen("t", "r");
      // $display(date_file);
      date_rc = $fgets(date_str, date_file);
      date_int = date_str.atoi();
      // $display(date_int);
      $fclose(date_file);
   endtask

   initial begin
      string  method;       // string to hold which test to do

      if ($value$plusargs("LOOP=%s", a)) begin
         loop = a.atoi();
      end else begin
         loop = 100000;
      end

      if ($value$plusargs("TESTNAME=%s", method)) begin
         if (method == "PERFORMANCE") begin
            for (longint i; i < loop; i = i + 1) begin
               perf_test();
            end
         end else begin
            // will write to output - return is rc of shell command only
            $display("hello");
            a = $system("date");
            $display(a);

            // will get the string value of date into date_str
            $display("hello");
            a = $system("date > t");
            date_file = $fopen("t", "r");
            // $display(date_file);
            date_rc = $fgets(date_str, date_file);
            $display(date_str);
            $fclose(date_file);

            // will get the seconds back into date_int
            $display("hello");
            a = $system("date +%s > t");
            date_file = $fopen("t", "r");
            // $display(date_file);
            date_rc = $fgets(date_str, date_file);
            date_int = date_str.atoi();
            $display(date_int);
            $fclose(date_file);
         end
      end
   end


endmodule
