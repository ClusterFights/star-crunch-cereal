/*
 * FILE : find.c
 *
 * This program takes a MD5 hash and searches
 * the gutenberg library for a 19 character string
 * that has the same MD5 hash.
 *
 * It uses an FPGA board that is connected via
 * an FTDI serial link to accelerate the processing
 * of strings into MD5 hashes to find the match.
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 11/12/2018
 *
 * Updates:
 * 01/26/2019 : Updated to use the parallel interface.
 */

#include "munchman.h"
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>

#define MAX_BOOKS 600

struct manifest_info
{
    int size;
    char file_path[100];
};

static char USEAGE[] = 
    "Usage: find [-l] [-s len] md5_hash\n"
    "   -l      local only, no FPGA connection\n"
    "   -q      quite mode.  Don't print book titles\n"
    "   -s len  length of strings to search 2..55 [default=19]\n";
static char *manifest_file = "manifest.txt";
static unsigned char target_hash[16] = {0};
static struct manifest_info manifest_list[MAX_BOOKS] = {0};
static int num_of_books = 0;
static int lflag = 0;   // process locally? No FPGA?
static int sflag = 0;   // set string length.
static int qflag = 0;   // quite mode

/*
 * Parses the manifest file.
 */
int parse_manifest(char *mfile)
{
    FILE *fp;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    int line_num = 0;
    int byte_count=0;
    char str[100];

    // Open filehandle to manifest file, mfile
    fp = fopen(mfile, "r");
    if (fp == NULL) {
        printf("ERROR parse_manifest: can't open %s\n", mfile);
        return -1;
    }

    while ((read = getline (&line, &len, fp)) != -1 ) {
        if (line_num >1) 
        {
            // Parse line
            sscanf(line, "%d %s",&byte_count, str);
            manifest_list[line_num-2].size = byte_count;
            strcpy(manifest_list[line_num-2].file_path,str);
            // XXX printf("%d, line length %d, %s\n",(line_num-2),manifest_list[line_num-2].size,manifest_list[line_num-2].file_path);
        } else if (line_num == 1)
        {
            // Parse num of files
            sscanf(line, "%s %d",str, &num_of_books);
            // XXX printf("num_of_books: %d\n",num_of_books);
            if (num_of_books > MAX_BOOKS)
            {
                printf("ERROR: too many books. num_of_books=%d, MAX_BOOKS=%d\n",num_of_books,MAX_BOOKS);
                return -1;
            }
        }
        line_num++;
    }

    // Clean up
    fclose(fp);
    free(line);

    return 0;
}

/*
 * Search the dataset for md5_hash
 */
int run()
{
    char ack;
    struct match_result match;
    struct timeval tv1, tv2;
    int num_hashes=0;
    long long total_proc_bytes=0;

    // Start the timer.
    gettimeofday(&tv1, NULL);

    // loop through all the books
    for (int i=0; i<num_of_books; i++)
    {
        if (!qflag) {
            printf("%i %s\n",i,manifest_list[i].file_path);
        }
        ack = send_file(manifest_list[i].file_path, &match, 
                lflag, target_hash, &num_hashes);
        if (ack == 1)
        {
            total_proc_bytes += num_hashes;
            // hash found.

            // Stop the timer
            gettimeofday(&tv2, NULL);
            double total_time = (double) (tv2.tv_usec - tv1.tv_usec) / 1000000 +
                 (double) (tv2.tv_sec - tv1.tv_sec);
            printf ("Total time = %f seconds\n", total_time);
            printf ("Total bytes processed = %lld \n", total_proc_bytes);
            // double hashes_per_sec = num_hashes / total_time;
            double hashes_per_sec = total_proc_bytes / total_time;
            printf("hashes_per_sec: %f\n",hashes_per_sec);


            return 1;
        } else if (ack < 0)
        {
            // error occured
            return ack;
        }
        total_proc_bytes += manifest_list[i].size;
    }

    return 0;
}


int main(int argc, char *argv[])
{
    char md5_hash_arg[32];
    int c;
    char ack;
    opterr = 0;

    // Parse comand line args.
    while ((c=getopt(argc, argv, "ls:q")) != -1)
    {
        switch(c)
        {
            case 'l':
                // l = local, don't use FPGA.
                lflag = 1;
                break;
            case 's':
                // s = set the string length
                sflag = 1;
                errno = 0;
                // NOTE: STR_LEN is defined in munchman.h
                STR_LEN = strtol(optarg,NULL,10);
                if (errno == ERANGE || STR_LEN <2 || STR_LEN >55)
                {
                    printf("ERROR with -s flag.\n");
                    printf("%s",USEAGE);
                    return EXIT_FAILURE;
                }
                break;
            case 'q':
                qflag = 1;
                break;
            default:
                printf("%s",USEAGE);
                return EXIT_FAILURE;
        }
    }
    // Get the hash arg
    if (optind < argc)
    {
        strcpy(md5_hash_arg,argv[optind++]);
        printf("md5_hash: %s\n",md5_hash_arg);
        printf("lflag: %d\n",lflag);
    } else {
        printf("%s",USEAGE);
        return EXIT_FAILURE;
    }

    // Check that md5_hash is 16 bytes or 32 chars.
    if (strlen(md5_hash_arg) != 32) {
        printf("ERROR: md5_hash must be 16 bytes or 32 hex chars.\n");
        printf("%s",USEAGE);
        return EXIT_FAILURE;
    }

    // Convert md5_hash_arg hex string to target_hash byte array.
    char tmp_str[2] ="00";
    printf("md5_hash_bytes: ");
    for (int i=0,j=0; i<32; i+=2,j++)
    {
        tmp_str[0] = md5_hash_arg[i];
        tmp_str[1] = md5_hash_arg[i+1];
        // XXX printf("%d %x \n",i,md5_hash_arg[i]);
        // XXX printf("%d %x \n",i+1,md5_hash_arg[i+1]);
        errno = 0;      // reset errno before strtol call
        target_hash[j] = (unsigned char)strtol(tmp_str,NULL,16);
        if (errno != 0)
        {
            printf("ERROR: with md5_hash during strtol\n");
            return EXIT_FAILURE;
        }
        printf("%.2x ",target_hash[j]);
    }
    printf("\n");

    // Parse the manifest.txt file
    parse_manifest(manifest_file);

    printf("lflag: %d\n",lflag);
    printf("sflag: %d\n",sflag);
    printf("STR_LEN: %d\n",STR_LEN);

    if (!lflag)
    {
        // Init and sync bus
        bus_write_config();
        sleep_ms(100);
        sync_bus();
        sleep_ms(100);

        // Send the test command 0x04.
        // XXX printf("Sending the test command 0x04.\n");
        // XXX cmd_test();

        // Send the set str len cmd 0x05.
        printf("Sending set str length command 0x05. STR_LEN=%d\n",STR_LEN);
        cmd_str_len(STR_LEN);

        // Send the set hash command 0x01.
        printf("Sending the set hash command 0x01.\n");
        ack = cmd_set_hash(target_hash);
        if (!ack) {
            printf("ERROR, during set hash command. ack=%d\n",ack);
            return EXIT_FAILURE;
        }

        // Run the search
        run();

    } else
    {
        // Process locally.

        // Run the search
        run();
    }

    return EXIT_SUCCESS;
}

