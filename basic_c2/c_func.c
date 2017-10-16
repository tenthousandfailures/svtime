#include<stdio.h>
#include<time.h>
#include<svdpi.h>

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

void svtime_example(svtime_struct *s1) {
  printf("C: gets values from SV, s1.tm_sec=%d, s1.tm_min=%d\n",s1->tm_sec,s1->tm_min);
  s1->tm_sec = 10;
  s1->tm_min = 20;
  printf("C: set values,  s1.tm_sec=%d, s1.tm_min=%d\n",s1->tm_sec,s1->tm_min);
}

// wrap python ctime function
// return seconds since epoc
char* c_ctime(time_t t) {
  char* string;
  time_t result;
  if (t < 0) {
    result = time(NULL);
  } else {
    result = time(t);
  }

  string = ctime(&result);
  return (string);
}

long int c_time() {
  // time_t seconds;
  return (time(NULL));
}

void c_localtime(time_t t, svtime_struct *s1) {
  svtime_struct st;
  time_t result;
  struct tm buf;

  if (t < 0) {
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
  char* a;

  a = asctime(s1);

  return (a);
}
