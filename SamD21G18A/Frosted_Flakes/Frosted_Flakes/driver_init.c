/*
 * Code generated from Atmel Start.
 *
 * This file will be overwritten when reconfiguring your Atmel Start project.
 * Please copy examples or other code you want to keep to a separate file
 * to avoid losing it when reconfiguring.
 */

#include "driver_init.h"
#include <peripheral_clk_config.h>
#include <utils.h>
#include <hal_init.h>
#include <hpl_gclk_base.h>
#include <hpl_pm_base.h>

struct spi_m_async_descriptor VidorSPI;

void VidorSPI_PORT_init(void)
{

	gpio_set_pin_level(PA16,
	                   // <y> Initial level
	                   // <id> pad_initial_level
	                   // <false"> Low
	                   // <true"> High
	                   false);

	// Set pin direction to output
	gpio_set_pin_direction(PA16, GPIO_DIRECTION_OUT);

	gpio_set_pin_function(PA16, PINMUX_PA16D_SERCOM3_PAD0);

	gpio_set_pin_level(PA17,
	                   // <y> Initial level
	                   // <id> pad_initial_level
	                   // <false"> Low
	                   // <true"> High
	                   false);

	// Set pin direction to output
	gpio_set_pin_direction(PA17, GPIO_DIRECTION_OUT);

	gpio_set_pin_function(PA17, PINMUX_PA17D_SERCOM3_PAD1);

	// Set pin direction to input
	gpio_set_pin_direction(PA19, GPIO_DIRECTION_IN);

	gpio_set_pin_pull_mode(PA19,
	                       // <y> Pull configuration
	                       // <id> pad_pull_config
	                       // <GPIO_PULL_OFF"> Off
	                       // <GPIO_PULL_UP"> Pull-up
	                       // <GPIO_PULL_DOWN"> Pull-down
	                       GPIO_PULL_OFF);

	gpio_set_pin_function(PA19, PINMUX_PA19D_SERCOM3_PAD3);
}

void VidorSPI_CLOCK_init(void)
{
	_pm_enable_bus_clock(PM_BUS_APBC, SERCOM3);
	_gclk_enable_channel(SERCOM3_GCLK_ID_CORE, CONF_GCLK_SERCOM3_CORE_SRC);
}

void VidorSPI_init(void)
{
	VidorSPI_CLOCK_init();
	spi_m_async_init(&VidorSPI, SERCOM3);
	VidorSPI_PORT_init();
}

void system_init(void)
{
	init_mcu();

	VidorSPI_init();
}
