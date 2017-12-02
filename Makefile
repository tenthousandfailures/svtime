TESTNAME = DEFAULT
# DEFAULT / PERFORMANCE1 / PERFORMANCE2

perf_stack: ## Do the SystemVerilog date wrapper (StackOverflow) performance benchmark
	cd system_solution; run.sh

perf_non_oo: ## Do the SystemVerilog static method performance benchmark
	cd basic_c2; run.sh

perf_oo: ## Do the SystemVerilog object-oriented preferred performance benchmark
	cd basic_c2; run.sh

perf_shell: ## Do the basic Linux shell version of the performance benchmark
	date; speed.sh; date

shared_c: ## Create the shared c library c_func.so
	gcc -shared -fPIC -v -I "${VCS_HOME}/include" -o c_func.so ./pkg/c_func.c

vcs_example_build: ## Build the example in VCS
	vcs -sverilog +vc -full64 -f example/tb.f

vcs_example_sim: ## Simulate the example in VCS
	./simv -sv_lib c_func +TESTNAME=$(DEFAULT)

clean: ## Cleans up work area
	@rm -f c_func.so
	@rm -f vc_hdrs.h
	@rm -f ucli.key
	@rm -f simv
	@rm -rf simv.vdb
	@rm -rf simv.daidir

help: ## Help Text
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Examples"
	@echo "    > make perf_stack"
	@echo "    > make perf_oo"
	@echo "    > make clean shared_c vcs_example_build vcs_example_sim"
	@echo ""
	@echo ""

.DEFAULT_GOAL := help
