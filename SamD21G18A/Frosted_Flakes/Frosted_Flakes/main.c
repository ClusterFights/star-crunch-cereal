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
				
	
	USB_CDC - USB	-NOT USED-
				Data+ PA25
				Data- PA24
				
*/
#include <atmel_start.h>

//Flag for checking if SPI bridge has sent data to Cyclone

bool spiComplete = false;

void send(uint8_t * data);

int main(void)
{
	/* Initializes MCU, drivers and middleware */
	atmel_start_init();
	
	char num = 0;
	
	/* Replace with your application code */
	while (1) 
	{
		if(spiComplete)
		{
			spiComplete = false;
			send(num);
			num++;
			if(num > 255)
				num = 0;
		}
	}
}


static void complete_VidorSPI(const struct spi_m_async_descriptor *const io_descr)
{
	spiComplete = true;
}

void send(uint8_t * data)
{
	struct io_descriptor *io;
	spi_m_async_get_io_descriptor(&VidorSPI, &io);

	spi_m_async_register_callback(&VidorSPI, SPI_M_ASYNC_CB_XFER, (FUNC_PTR)complete_VidorSPI);
	spi_m_async_enable(&VidorSPI);
	io_write(io, data, sizeof(data));
}
