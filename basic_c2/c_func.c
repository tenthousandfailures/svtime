#include<stdio.h>
#include<time.h>
#include<svdpi.h>
#include<unistd.h>

// where time comes from
// /usr/include/time.h

typedef struct {
  int tm_sec;
  int tm_min;
  int tm_hour;
  int tm_mday;
  int tm_mon;
  int tm_year;
  int tm_wday;
  int tm_yday;
  int tm_isdst;
}  svtime_struct;

// #define __CLOCK_T_TYPE		__SYSCALL_SLONG_TYPE
// #define __TIME_T_TYPE		__SYSCALL_SLONG_TYPE

void c_sleep(int t) {
  sleep(t);
  return;
}

char* c_ctime(long int t) {
  return (asctime(localtime(&t)));
}

char* c_strftime(int bsize, char* fmt, svtime_struct *s1, char* target) {
  char str[bsize];

  strftime(str, bsize, fmt, s1);
  // printf("C: c_strftime %s", str);
  target = (char*)malloc((strlen(str) + 1) * sizeof(char));
  strcpy(target, str);

  return (target);
}

long int c_time() {
  return (time(NULL));
}

long int c_mktime(svtime_struct *s1) {
  return(mktime(s1));
}


void c_localtime(long int  t, svtime_struct *s1) {
  svtime_struct st;
  time_t result;
  struct tm buf;

  if (t == 0) {
    result = time(NULL);
  } else {
    result = time(t);
  }

  buf = *localtime(&result);
  s1->tm_sec = buf.tm_sec;
  s1->tm_min = buf.tm_min;
  s1->tm_hour = buf.tm_hour;
  s1->tm_mday = buf.tm_mday;
  s1->tm_mon = buf.tm_mon;
  s1->tm_year = buf.tm_year;
  s1->tm_wday = buf.tm_wday;
  s1->tm_yday = buf.tm_yday;
  s1->tm_isdst = buf.tm_isdst;

  return;
}

char* c_asctime(svtime_struct *s1) {
  return (asctime(s1));
}
