/*  
test_toggle.c

Toggles pin 21 on the rpi.
Also connect a ground between rpi and ArtyS7.

Compile:
 gcc $GPIO_BASE -Wall -o test_toggle test_toggle.c && sudo chown root test_toggle && sudo chmod +s test_toggle

Run:
 ./test_toggle

*/
#include <time.h>
#include <sys/time.h>

#define PI_GPIO_ERR  // errno.h
#include "PI_GPIO.c" // stdio.h, sys/mman.h, fcntl.h, stdlib.h - signal.h
#define PI_OUT (21)

void sleep_ms(int ms) 
{
    struct timespec ts; 
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000000;
    nanosleep(&ts, NULL);
}

int main(int argc, char *argv[]) {
    int state=0;
    int i;
    struct timeval tv1, tv2;
    PI_GPIO_config(PI_OUT, BCM_GPIO_OUT);

    gettimeofday(&tv1, NULL);
    for (i=0; i< 2000; i++)
    {
        if (state==1)
        {
            GPIO_SET_N(PI_OUT);
            state=0;
        } else
        {
            GPIO_CLR_N(PI_OUT);
            state=1;
        }
        // Sleep for .5 seconds
        // sleep_ms(500);
    }
    gettimeofday(&tv2, NULL);

    double total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
    (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("Total time = %f seconds\n", total_time);
    double toggles_per_sec = 1000 / total_time;
    printf("toggles_per_sec: %f\n",toggles_per_sec);

}

