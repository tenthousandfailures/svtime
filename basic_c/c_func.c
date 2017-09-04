#include<stdio.h>
#include<time.h>
#include<svdpi.h>

// where time comes from
// /usr/include/time.h


void print_hello() {
  printf("hello world from c \n");
}

int simple_add(int a, int b) {
  return (a+b);
}

void simple_time() {
  time_t seconds;

  seconds = time(NULL);
  printf("value of seconds is %d \n", seconds);
}

// definition of time_t type long int
// #define __TIME_T_TYPE		__SYSCALL_SLONG_TYPE
// ./bits/typesizes.h:# define __SYSCALL_SLONG_TYPE	__SLONGWORD_TYPE
// ./bits/types.h:#define __SLONGWORD_TYPE	long int

long int simple_time_seconds() {
  // time_t seconds;
  return (time(NULL));
}
