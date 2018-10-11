/*
 * Code generated from Atmel Start.
 *
 * This file will be overwritten when reconfiguring your Atmel Start project.
 * Please copy examples or other code you want to keep to a separate file
 * to avoid losing it when reconfiguring.
 */

#include "driver_examples.h"
#include "driver_init.h"
#include "utils.h"

/**
 * Example of using VidorSPI to write "Hello World" using the IO abstraction.
 *
 * Since the driver is asynchronous we need to use statically allocated memory for string
 * because driver initiates transfer and then returns before the transmission is completed.
 *
 * Once transfer has been completed the tx_cb function will be called.
 */

static uint8_t example_VidorSPI[12] = "Hello World!";


static void complete_cb_VidorSPI(const struct spi_m_async_descriptor *const io_descr)
{
	/*spiComplete = true;*/
}

void VidorSPI_example(void)
{
	struct io_descriptor *io;
	spi_m_async_get_io_descriptor(&VidorSPI, &io);

	spi_m_async_register_callback(&VidorSPI, SPI_M_ASYNC_CB_XFER, (FUNC_PTR)complete_cb_VidorSPI);
	spi_m_async_enable(&VidorSPI);
	io_write(io, example_VidorSPI, 12);
}
