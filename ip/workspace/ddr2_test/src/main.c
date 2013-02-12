/*
 * main.c
 *
 *  Created on: Jan 24, 2013
 *      Author: Victor Zhang
 */

#include <stdio.h>
#include <stdbool.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xutil.h"

#define printf xil_printf   /* a smaller footprint printf */
#define NUM_TEST_WORDS 8
#define TEST_VECTOR 0x12345678 /* random word */

#define TEST_FIFO

int main() {
	volatile u32 *ddr_addr = (volatile u32 *) XPAR_S6DDR_0_S0_AXI_BASEADDR;

	printf(
			"32-bit test: %s\n\r",
			(XST_SUCCESS == XUtil_MemoryTest32(ddr_addr, NUM_TEST_WORDS,
					TEST_VECTOR, XUT_ALLMEMTESTS)) ? "passed" : "failed");

	volatile int *hdmi_addr = (int *) XPAR_HDMI_OUT_0_BASEADDR;

#ifdef TEST_FIFO
	volatile int *hdmi_offset_addr = hdmi_addr + 0x40;

	// fill up off-chip memory with known values
	int i, j;
	for (j = 0; j < 720; j++) {
		for (i = 0; i < 1280; i++) {
			ddr_addr[j * 1280 + i] = j*1280 + i;
		}
	}

	// set register values
	//software control bits:
	//slv_reg0[2] = restart for fifo fsm
	//slv_reg0[3] = start for fifo fsm
	//slv_reg1 = FRAME_BASE_ADDR
	//slv_reg0[13:4] is LINE_STRIDE (10 bits)
	//slv_reg0[23:14] is PIXELS_PER_LINE (10 bits)
	//slv_reg0[27:24] is num bytes per pixel (4 bits)
	//slv_reg0[28] is fill_half_fifo_I when toggled
	//slv_reg0[29] is hsync_I when toggled
	//slv_reg0[30] is vsync_I when toggled

	//**NOTE:** hdmi_addr maps to slv_reg in hardware!!
	//			hdmi_offset_set maps to mst_reg in hardware!!

	hdmi_offset_addr[0] = 0x1 | 0x8; // read and burst
	hdmi_addr[1] = ddr_addr; // hdmi_addr[1] corresponds to slv_reg1
	hdmi_offset_addr[2] = 0x0000ffff; // byte enable
	hdmi_offset_addr[3] = (1280 * 4); // set transfer length of one line of 32-bit words

	// reset high

	hdmi_addr[0] = 1 << 2 | (1 << 0); // slv_reg0[2] = 1'b1

	int write_val = (1 << 1) | (0 << 2) /* restart = 0 */| (1 << 3)
	/* start = 1 */| (1280 << 4) /* set line_stride */| (64 << 14)
	/* pixels per line */| (4 << 24) /* 4 bytes per pixel */;

	hdmi_addr[0] = write_val; // start FSM, it should now trigger the first read of 64 pixels.
#endif

#ifdef TEST_DDR
	volatile int *hdmi_offset_addr = hdmi_addr + 0x40;

	int i;
	for (i = 0; i < 1024; i++) {
		ddr_addr[i] = 0xdead0000 | i;
	}

	//software control bits for fill_fifo_fsm:
	//hdmi_addr[0] bit [2] = restart for fifo fsm
	//hdmi_addr[0]  bit [3] = start for fifo fsm
	//hdmi_addr[1] = FRAME_BASE_ADDR
	//hdmi_addr[0] bits [13:4] is LINE_STRIDE (10 bits)
	//hdmi_addr[0] bits [23:14] is PIXELS_PER_LINE (10 bits)
	//hdmi_addr[0] bits [27:24] is num bytes per pixel (4 bits)


	hdmi_offset_addr[0] = 0x1 | 0x8; // read and burst
	hdmi_offset_addr[1] = ddr_addr;
	hdmi_offset_addr[2] = 0x0000ffff; // byte enable
	hdmi_offset_addr[3] = 0x0a000000 | (64 * 4); // go and transfer length of 64 32-bit words

	// poll on done signal
	while ((hdmi_offset_addr[0] & 0x100) == 0) {
	}
	hdmi_offset_addr[0] = hdmi_offset_addr[0] & ~0x100;

	printf("%x %x\n\r", hdmi_addr[0], hdmi_addr[1]);

	// Increment address
	hdmi_offset_addr[1] = ddr_addr + 64;
	hdmi_offset_addr[3] = 0x0a000000 | (64 * 4); // go and transfer length of 64 32-bit words

	// poll on done signal
	while ((hdmi_offset_addr[0] & 0x100) == 0) {
	}
	hdmi_offset_addr[0] = hdmi_offset_addr[0] & ~0x100;

	printf("%x %x\n\r", hdmi_addr[0], hdmi_addr[1]);

	// Increment address
	hdmi_offset_addr[1] = ddr_addr + 128;
	hdmi_offset_addr[3] = 0x0a000000 | (64 * 4); // go and transfer length of 64 32-bit words

	// poll on done signal
	while ((hdmi_offset_addr[0] & 0x100) == 0) {
	}
	hdmi_offset_addr[0] = hdmi_offset_addr[0] & ~0x100;

	printf("%x %x\n\r", hdmi_addr[0], hdmi_addr[1]);
#endif

#ifdef TEST_HDMI

	hdmi_addr[0] = 1; // reset
	hdmi_addr[1] = 0x00000000; // write 000000 (RGB for black) as the colour
	hdmi_addr[0] = 2; // GO!

	bool done = false;

	while (!done) {
		printf(
				"Press r, g or b to get respective colors. Any other key exits.\n\r");
		char get = 0x0;
		while (!get) {
			get = (char) *(volatile int *) (XPAR_RS232_UART_1_BASEADDR);
			if (get == 'r') {
				hdmi_addr[0] = 1; // reset
				hdmi_addr[1] = 0x00FF0000; // write 1188ff (RGB) as the colour
				hdmi_addr[0] = 2; // GO!
			} else if (get == 'g') {
				hdmi_addr[0] = 1; // reset
				hdmi_addr[1] = 0x0000FF00; // write 1188ff (RGB) as the colour
				hdmi_addr[0] = 2; // GO!
			} else if (get == 'b') {
				hdmi_addr[0] = 1; // reset
				hdmi_addr[1] = 0x000000FF; // write 1188ff (RGB) as the colour
				hdmi_addr[0] = 2; // GO!
			} else if (get != 0) {
				done = true;
			}
		}
	}

	hdmi_addr[0] = 1;
#endif

	printf("Exiting\n\r");

	return 0;
}
