rm -rf simv.vdb;
rm -rf simv.daidir;
vcs -sverilog -debug_access+all -lca -kdb -full64 -f tb.f;
./simv +UVM_TESTNAME=random_test
