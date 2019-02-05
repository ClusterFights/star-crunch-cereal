/*
 * FILE : md5.c
 *
 * This program is a reference implementation of
 * the md5 hash algorithm.  It purposed is to understand
 * the algorithm and generate test vectors for the 
 * Verilog implmentation.
 *
 * The algorithm followed is from the wikipedia article,
 * https://en.wikipedia.org/wiki/MD5
 *
 * Used the following code as reference:
 * https://github.com/Toms42/fpga-hash-breaker/blob/master/test%20stuff/c_eample.c
 *
 * AUTHOR : Brandon Blodget
 * CREATE DATE: 10/14/2018
 */

#include "md5.h"

// s specifies the per-round shift amounts
static const int s[64] = {
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
};

// k constants, binary integer part of the sines of integers (Radians)
static const int k[64] = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
};



int md5(uint8_t *initial_msg, uint8_t *hash_byte)
{
    uint8_t msg[64] = {0};
    int initial_len = strlen((char *)initial_msg);

    // Since the ClusterFight Challenge is using a string size
    // of 19-bytes, we will assume the initial_msg will be
    // less than 56 bytes.  That way we will only have to
    // process 1 512-bit (64 byte) chunk.

    if (initial_len >= 56)
    {
        printf("ERROR: initial_msg size >= 56: %d",initial_len);
        return -1;
    }

    // copy the initial_msg into the bigger msg array.
    // Already has the zero padding for 448 bits (64 bytes).
    memcpy(msg, initial_msg, initial_len);

    // Pre-processing: add a single 1 bit
    // Notice: the input bytes are considered as bits strings,
    // where the first bit is the most significant bit of the byte.
    msg[initial_len] = 128; // append the "1" bit

    // Append the initial_len in bits starting at msg[56]
    // Written in little endian format.
    int bits_len = 8*initial_len;
    memcpy(&msg[56], &bits_len, 4);

    // Print out the msg.
    /*
    printf("msg=");
    for (int i=0; i<64; i++)
    {
        printf("%.2x",msg[i]);
        if ((i+1)%4==0 & i!=63)
            printf("_");
    }
    printf("\n");
    */

    // Break into sixteen 32-bit words m[j] 0<= j <= 15
    uint32_t *m;
    m = (uint32_t *)(msg);
    /*
    printf("int=");
    for (int i=0; i<16; i++)
    {
        printf("%.8x ",m[i]);
    }
    printf("\n");
    */

    // Initialize hash values
    uint32_t a = 0x67452301;
    uint32_t b = 0xefcdab89;
    uint32_t c = 0x98badcfe;
    uint32_t d = 0x10325476;
    uint32_t f, g, temp;


    // Main loop
    for (int i=0; i<64; i++)
    {
        if (i<16)
        {
            f = (b & c) | ((~b) & d);
            g = i;
        }
        else if (i<32)
        {
            f = (d & b) | ((~d) & c);
            g = (5*i + 1) % 16;
        }
        else if (i<48)
        {
            f = b ^ c ^ d;
            g = (3*i + 5) % 16;
        }
        else
        {
            f = c ^ (b | (~d));
            g = (7*i) % 16;
        }

        // Update for next loop.
        temp = f + a + k[i] + m[g];
        a = d;
        d = c;
        c = b;
        b = b + LEFTROTATE(temp, s[i]);

        // XXX printf("%d) a=%x b=%x c=%x d=%x f=%x k[i]=%x s[i]=%x m[g]=%x\n",i,a,b,c,d,f,k[i],s[i],m[g]);
    }

    a += 0x67452301;
    b += 0xefcdab89;
    c += 0x98badcfe;
    d += 0x10325476;

    uint8_t *pa = (uint8_t *)&a;
    uint8_t *pb = (uint8_t *)&b;
    uint8_t *pc = (uint8_t *)&c;
    uint8_t *pd = (uint8_t *)&d;

    hash_byte[0] = pa[0];
    hash_byte[1] = pa[1];
    hash_byte[2] = pa[2];
    hash_byte[3] = pa[3];

    hash_byte[4] = pb[0];
    hash_byte[5] = pb[1];
    hash_byte[6] = pb[2];
    hash_byte[7] = pb[3];

    hash_byte[8] = pc[0];
    hash_byte[9] = pc[1];
    hash_byte[10] = pc[2];
    hash_byte[11] = pc[3];

    hash_byte[12] = pd[0];
    hash_byte[13] = pd[1];
    hash_byte[14] = pd[2];
    hash_byte[15] = pd[3];

    return 0;

}

/*
 * Helper functions to print a hash string
 */
void print_hash(unsigned char *hash)
{
    for (int i=0; i<16; i+=4)
    {
        printf("%.2x%.2x%.2x%.2x",hash[i],hash[i+1],hash[i+2],hash[i+3]);
        if (i<12)
        {
            printf("_");
        }

    }
    printf("\n");
}

