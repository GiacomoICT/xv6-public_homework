#include "user.h"
#include "types.h"

static inline uint64 rdtscp(void)
{
  uint32 lo, hi;

  __asm__ __volatile__ (
    "rdtscp"
    : "=a" (lo), "=d" (hi)
    :
    : "ecx"
  );

  return ((uint64)hi << 32) | lo;
}


int
main(int argc, char *argv[]){
  
  char *input;
  uint64 clock_start;
  uint64 clock_end;
  int elaps_time;
  int pid;
  
  
  if (argc < 2){
    printf(2, "Missing Arguments\n");
    exit();
  }    
    
  clock_start = rdtscp();
  if ((pid = fork()) == 0){
    exec(argv[1], argv);
  } 
  wait();

  clock_end = rdtscp();
  
  elaps_time = clock_end - clock_start;
  printf(1, "Elapsed Time is: %d \n", elaps_time);
  exit();
}
