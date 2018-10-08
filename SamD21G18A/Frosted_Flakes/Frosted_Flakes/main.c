/*
	Frosted Flakes:
	A mainly plain cereal with a bit of added sugar. This is a test program and meant to
	offer solid foundation for the challenges to come. Normally I would say corn flakes
	are my go to but in this case we are using the higher level initializations of Atmel Start.
	When we chose to go a more bare metal approach in the time to come you can find me eating some
	corn flakes. For now, I will rely on the added sugar.
	
	Peripherals:
	VidorSPI - Sercom3
				MISO PA19
				MOSI PA16
				SCK  PA17
				CS - N/A <-- Haven't picked yet
				
	USB_CDC - USB
				Data+ PA25
				Data- PA24
				
*/
#include <atmel_start.h>

int main(void)
{
	/* Initializes MCU, drivers and middleware */
	atmel_start_init();

	/* Replace with your application code */
	while (1) {
	}
}
