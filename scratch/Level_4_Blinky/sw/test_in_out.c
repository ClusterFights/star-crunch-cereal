/*  test_in_out.c by Yann Guidon whygee@f-cpu.org
   version sam. juil. 26 10:05:03 CEST 2014
   version mar. nov.  1 21:16:31 CET 2016 : english@HaD

Copies the state of one input pin to an output pin.

Compile:
 gcc $GPIO_BASE -Wall -o test_in_out test_in_out.c && sudo chown root test_in_out && sudo chmod +s test_in_out

Run:
 ./test_in_out

*/

#define PI_GPIO_ERR  // errno.h
#include "PI_GPIO.c" // stdio.h, sys/mman.h, fcntl.h, stdlib.h - signal.h
#define PI_IN  (4)
#define PI_OUT (25)

int main(int argc, char *argv[]) {
  PI_GPIO_config(PI_IN,  BCM_GPIO_IN);
  PI_GPIO_config(PI_OUT, BCM_GPIO_OUT);

  while (1) {
    printf("GPIO4=%d\n", GPIO_LEV_N(PI_IN));
    if (GPIO_LEV_N(PI_IN))
      GPIO_SET_N(PI_OUT);
    else
      GPIO_CLR_N(PI_OUT);
  }
}
