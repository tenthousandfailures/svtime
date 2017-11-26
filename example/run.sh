rm -rf c_func.so
rm -rf simv.vdb
rm -rf simv.daidir

gcc -shared -fPIC -v -I "${VCS_HOME}/include" -o c_func.so ../pkg/c_func.c
# -v

vcs -sverilog +vc -full64 -f tb.f
./simv -sv_lib c_func +TESTNAME=DEFAULT
# ./simv -sv_lib c_func +TESTNAME=PERFORMANCE1
# ./simv -sv_lib c_func +TESTNAME=PERFORMANCE2
