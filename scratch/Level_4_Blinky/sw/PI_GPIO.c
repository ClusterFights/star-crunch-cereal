/*
 PI_GPIO.c  (c) Yann Guidon 20130204
 GPIO access for the Raspberry Pi
 Derived from code by Dom & Gert
  @ http://elinux.org/RPi_Low-level_peripherals version 20130101

  20130507 : mmap : corrected return value (MAP_FAILED)
  20130508 : adapted for use with SPI
  20130513
  20130527 stupid mask bug found ! avoid previous versions !!!
  20130611 added input macro
  20140726 "parachute" function
  20140904 err()
  20140907 : everything goes to stderr
  20161101 : #ifndef GPIO_BASE, english
*/

#ifndef PI_GPIO
#define PI_GPIO

#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>

int mmap_fd=0;

#ifndef GPIO_BASE
#define GPIO_BASE  (0x20200000)
// For RPi2, declare under bash GPIO_BASE="-DGPIO_BASE=(0x3F200000)"
// (or whatever the platform-of-the-day requires)
#endif
#define BLOCK_SIZE (4096) /* size of one MMU page */

// if the erreur() function is not provided
#ifdef PI_GPIO_ERR
#include <errno.h>

/* exits with a contextualised error message */
void erreur(char *msg) {
  perror(msg);
  exit(EXIT_FAILURE);
}

// 2nd error message, without perror
void err(char *msg) {
  fputs(msg, stderr);
  fputc('\n', stderr);
  exit(EXIT_FAILURE);
}
#endif

unsigned * PI_IOmmap(off_t where) {
   void* map;

   // don't reopen /dev/mem if it's already open
   if (mmap_fd <= 0) {
     // open /dev/mem
     if ((mmap_fd = open("/dev/mem", O_RDWR|O_SYNC) ) < 0)
       erreur("Failed to open /dev/mem");
   }

   // map the GPIO registers in the program's memory
   map = mmap(
      NULL,             // map wherever it pleases the kernel
      BLOCK_SIZE,       // the GPIO registers fit inside a single page
      PROT_READ|PROT_WRITE, // we want to read and write
      MAP_SHARED,       // shared with other processes
      mmap_fd,          // the memory
      where             // address of the area to access
   );

   if (map == MAP_FAILED)
     erreur("mmap() failed");

   return (unsigned*)map;
}


volatile unsigned *PI_gpio=NULL; // MUST be volatile
// Set or Clear the pins :
#define RPI_GPSET0   (7)
#define RPI_GPCLR0  (10)
#define RPI_GPLEV0  (13)
#define GPIO_SET    *(PI_gpio+RPI_GPSET0)
#define GPIO_CLR    *(PI_gpio+RPI_GPCLR0)
#define GPIO_LEV    *(PI_gpio+RPI_GPLEV0)

#define GPIO_SET_N(N) GPIO_SET = (1 << N)
#define GPIO_CLR_N(N) GPIO_CLR = (1 << N)
#define GPIO_LEV_N(N) (((GPIO_LEV) >> N) &1)

#define BCM_GPIO_IN   (0)
#define BCM_GPIO_OUT  (1)
#define BCM_GPIO_ALT0 (4)
#define BCM_GPIO_ALT1 (5)
#define BCM_GPIO_ALT2 (6)
#define BCM_GPIO_ALT3 (7)
#define BCM_GPIO_ALT4 (3)
#define BCM_GPIO_ALT5 (2)
#define BCM_GPIO_ALT3 (7)


#ifndef GPIO_NO_ATEXIT
unsigned long long int GPIO_used=0; // List of the pins to disable
void GPIO_parachute(); // pre-declaration

#include <signal.h>
#endif

// Call this before accessing any pin !
void PI_GPIO_config(int port, int mode) {
  int registre, offset, temp;

  // the first call will mmap
  if (PI_gpio == NULL)
    PI_gpio = PI_IOmmap(GPIO_BASE); // adress of the GPIO ports

  if ((port >= 0) && (port < 32) // Works up to 54
      // but the macros don't handle more than 32 GPIO
   && (mode >= 0) && (mode < 8 )) {
    // Compute the register number
    registre = port/10;

    // Read the config register
    temp = *(PI_gpio+registre);

    // Computes the offset
    offset = port - (registre*10); // disguised modulo
    offset *= 3; // 3 bits per port

    // Clear the previous bits
    temp &= ~(7 << offset);
    // add the desired mode
    temp |= mode << offset;

    // overwrite the result
    *(PI_gpio+registre) = temp;

#ifndef GPIO_NO_ATEXIT
    if (mode != 0) {
      // record the pin number for later disable
      if ( GPIO_used == 0 ) {
        atexit(GPIO_parachute);
        // When a signal is received, stop the program
        // and indirectly call GPIO_parachute :
        signal(SIGHUP,  exit);
        signal(SIGINT,  exit);
        signal(SIGQUIT, exit);
        signal(SIGSTOP, exit);
        signal(SIGTERM, exit);
        signal(SIGABRT, exit);
        signal(SIGKILL, exit);
      }
      GPIO_used |= 1UL << port;
    }
#endif
  }
  else {
    fprintf(stderr,"Wrong port number (%d) or wrong mode (%d)\n", port, mode);
    exit(EXIT_FAILURE);
  }
}

#ifndef GPIO_NO_ATEXIT

void GPIO_parachute() {
  unsigned int GPIO_cache = GPIO_used;
  unsigned int mask = 1;
  int i=0;

 fputs("\nSetting pins", stderr);
  while (GPIO_cache) {
    if (GPIO_cache & mask) {
      PI_GPIO_config(i, BCM_GPIO_IN);
      GPIO_cache &= ~mask;
      fprintf(stderr, " %d", i);
    }
    mask += mask; // décalage à gauche
    i++;
  }

  fputs(" as input\n", stderr);
}

#endif

#endif
