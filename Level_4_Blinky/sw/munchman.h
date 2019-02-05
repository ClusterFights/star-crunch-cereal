/*
 * FILE : munchman.h
 *
 * Library of functions for the Munchman project.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/04/2018
 *
 * Updates:
 * 01/25/2019 : Updates for new parallel bus
 */

#ifndef _MUNCHMAN_H_
#define _MUNCHMAN_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
// XXX #include <ftdi.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>

/*
***************************
* Constants
***************************
*/
#define BUFFER_SIZE 65000

// Parallel Bus GPIOs
#define DATA0   (21)
#define DATA1   (20)
#define DATA2   (16)
#define DATA3   (12)
#define DATA4   (25)
#define DATA5   (24)
#define DATA6   (23)
#define DATA7   (18)
#define RNW     (26)
#define CLK     (19)
#define DONE    (13)
#define MATCH   (6)

/*
***************************
* Structures
***************************
*/

struct match_result
{
    int pos;
    unsigned char str[56];
};

/*
***************************
* Variables
***************************
*/
extern unsigned char ret_buffer[];

extern unsigned int set_reg;
extern unsigned int clr_reg;

extern unsigned int read_pins;
extern unsigned char read_val;

extern int STR_LEN;

/*
***************************
* Functions
***************************
*/

void sleep_ms(int ms);
void sleep_us(int us);
void sync_bus();
unsigned char wait_bus_done();
void bus_write_config();
void bus_read_config();
void bus_write(unsigned char byte);
unsigned char bus_read();
int bus_read_data(unsigned char *buffer, int num_to_read);
int bus_write_data(unsigned char *buffer, int num_to_write);

void cmd_test();
char cmd_set_hash(unsigned char *target_hash);
char cmd_send_text(unsigned char *text_str, int text_str_len);
char cmd_read_match(struct match_result *result);
char cmd_str_len(unsigned char num_chars);

unsigned char send_file(char *filename, struct match_result *match, int lflag,
        unsigned char *target_hash, int *num_hashes);


#ifdef __cplusplus
}
#endif

#endif

