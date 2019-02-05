/*
 * FILE : md5.h
 *
 * Header file for the md5 function.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/14/2018
 */

#ifndef _MD5_H_
#define _MD5_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdint.h>
#include <string.h>


/*
***************************
* Macro
***************************
*/
// leftrotate function definition
#define LEFTROTATE(x, c) (((x) << (c)) | ((x) >> (32 - (c))))

/*
***************************
* Function
***************************
*/
int md5(uint8_t *initial_msg, uint8_t *hash_byte);
void print_hash(unsigned char *hash);


#ifdef __cplusplus
}
#endif

#endif

