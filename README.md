# Welcome

This is the Github repository to support the DVCon (Design and Verification) 2018 Paper "What Time Is It: Implementing a SystemVerilog Object-Oriented Wrapper for Interacting with the C Library time" by Eldon Nelson.

# Abstract

Simulation time is the time within the SystemVerilog simulation which can be obtained by running the built-in $time function. Wall-time is the time you see on your watch; the actual time in space that we are all experiencing together. SystemVerilog users are attempting to mark when a test started in the simulation log for post processing, determine how long in wall-time a sequence takes to run, or conduct simulator performance experiments. The wall-time query with most other programming languages is common and easily answered. Unfortunately, SystemVerilog does not have access to wall-time, out-of-the-box. This lack of the wall-time query has resulted in less than optimal understanding and solutions to get to the wall-time from the SystemVerilog simulation. This paper discusses design choices and motivations, and provides the source code for a userfriendly SystemVerilog object-oriented wrapper to interact with the C library time . The proposed approach is several hundred times faster than conventional $system functions. In addition, an approach to determining key bottlenecks in simulation runs is proposed by plotting the simulation time versus wall-time.

# Summary

A common question within the SystemVerilog community is how to get the wall-time during the simulation. There is no built-in method within SystemVerilog to get wall-time. This paper documents the development and motivations of a SystemVerilog object-oriented wrapper of the C library time. The design of this wrapper is based upon the objectoriented solutions from the Python time library and the Ruby Time library. The solution was built up over small steps with working solutions in between. The solution is released under the GNU GPL license and available on GitHub.

The svtime package provides a non-object-oriented implementation of the wrapper, which is very similar to the Python time implementation. This Python style time library uses purely static methods and a struct matching that of the C time library. Also provided in the svtime package is a Ruby style object-oriented implementation. This uses, in contrast, an object to handle the conversions and functions in an object-oriented style. The author prefers the Ruby style implementation and recommends that version for ease-of-use at a small, but reasonable, overhead of 3% over the Python style. The performance benefit of using a SystemVerilog DPI wrapper is 801 times faster than a common solution using $system, as documented on Stack Overflow.

# Makefile

There is an included Makefile in this project with many targets below. You can see all of the targets by typing "make help".

```
  > make help
  
  clean               Cleans up work area
  help                Help Text
  perf_non_oo         Do the SystemVerilog static method performance benchmark
  perf_oo             Do the SystemVerilog object-oriented preferred performance benchmark
  perf_shell          Do the basic Linux shell version of the performance benchmark
  perf_stack          Do the SystemVerilog date wrapper (Stack Overflow) performance benchmark
  shared_c            Create the shared c library c_func.so
  vcs_example_build   Build the example in VCS
  vcs_example_sim     Simulate the example in VCS

  Examples
  > make clean shared_c vcs_example_build vcs_example_sim
  > make perf_stack
  > make perf_oo# svtime
```

# Example Usage

```systemverilog
  svtimep svtimep_inst;
  ...
  svtimep_inst = new();
  svtimep_inst.now();
  $display("\t svtimep_inst.to_s() = %s", svtimep_inst.to_s());
  $display("\t svtimep_inst.sec() = %0d", svtimep_inst.sec());
  $display("\t svtimep_inst.min() = %0d", svtimep_inst.min());
  svtime::sleep(2);
  svtimep_inst.now();
  $display("\t svtimep_inst.to_s() = %s", svtimep_inst.to_s());
```

## Example Usage Output

```
  svtimep_inst.to_s() = 2017-11-16 01:37:07
  svtimep_inst.sec() = 7
  svtimep_inst.min() = 37
  svtimep_inst.to_s() = 2017-11-16 01:37:09
```

# Future

The goal of this project is to provide a community supported standard library for SystemVerilog to interact with system (wall-clock) time. The project is opensource under the GPL license and encourages contributions.
