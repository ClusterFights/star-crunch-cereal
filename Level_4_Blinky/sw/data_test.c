/*  
* data_test.c
* 
* This program sends sequential bytes 0..255 over
* the parallel interface to the ArtyS7 board.
* It then reads one byte back.  1 indicates success,
* 0 fail.
* 
* Author: Brandon Blodget
* Create Date: 01/22/2019
*/
#include "munchman.h"


int main(int argc, char *argv[]) {
    int i;
    struct timeval tv1, tv2;

    bus_write_config();

    printf("syncing... \n");
    sync_bus();

    // Send bytes 0..256
    gettimeofday(&tv1, NULL);
    for (i=0; i< 256; i++)
    {
        // XXX printf("i: %d\n",i);
        bus_write((unsigned char)i);
        // Sleep for for a bit
        // XXX sleep_ms(1000);
    }
    gettimeofday(&tv2, NULL);

    double total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
    (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("send total time = %f seconds\n", total_time);
    double bytes_per_sec = 256 / total_time;
    printf("send bytes_per_sec: %f\n",bytes_per_sec);

    // Receive bytes.

    // Change the bus direction to read from FPGA
    bus_read_config();


    // TODO : Remove this.
    sleep_us(300);

    // Read 256 bytes
    unsigned char val;
    gettimeofday(&tv1, NULL);
    for (i=0; i< 256; i++)
    {
        val = bus_read();

        if (val != i) {
            printf("i: %d, read_val: %d\n",i,val);
        }

        // Sleep for for a bit
        // XXX sleep_ms(10);
    }
    gettimeofday(&tv2, NULL);

    total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
        (double) (tv2.tv_sec - tv1.tv_sec);
    printf ("recv total time = %f seconds\n", total_time);
    bytes_per_sec = 256 / total_time;
    printf("recv bytes_per_sec: %f\n",bytes_per_sec);
}

