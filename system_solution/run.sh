rm -rf simv.vdb;
rm -rf simv.daidir;
vcs -sverilog -full64 -f tb.f;
# ./simv +TESTNAME=PERFORMANCE
./simv +TESTNAME=DEFAULT
