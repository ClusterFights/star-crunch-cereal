/*  test_in.c by Yann Guidon whygee@f-cpu.org
   version sam. juil. 26 09:01:56 CEST 2014
   version mar. nov.  1 19:46:22 CET 2016 : english@HaD

Compile:
 gcc -Wall -o test_in test_in.c && sudo chown root test_in && sudo chmod +s test_in

Run:
 ./test_in

*/

#include <unistd.h>  // usleep

#define PI_GPIO_ERR  // errno.h
#include "PI_GPIO.c" // stdio.h, sys/mman.h, fcntl.h, stdlib.h - signal.h

#define PI_PIN (7)

int main(int argc, char *argv[]) {
  PI_GPIO_config(PI_PIN, BCM_GPIO_IN);

  while (1) {
    usleep(100*1000);   /* wait for 100ms */
    printf("GPIO7=%d\n", GPIO_LEV_N(PI_PIN));
  }
}
