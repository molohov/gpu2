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
#define TEST_SYSTEM

int main() {
	volatile u32 *ddr_addr = (volatile u32 *) XPAR_S6DDR_0_S0_AXI_BASEADDR;

	printf(
			"32-bit test: %s\n\r",
			(XST_SUCCESS == XUtil_MemoryTest32(ddr_addr, NUM_TEST_WORDS,
					TEST_VECTOR, XUT_ALLMEMTESTS)) ? "passed" : "failed");

	volatile int *hdmi_addr = (int *) XPAR_HDMI_OUT_0_BASEADDR;
	volatile int *hdmi_offset_addr = hdmi_addr + 0x40;

	int write_val = 0;

	// fill up off-chip memory with known values
	int i, j;
	for (j = 0; j < 720; j++) {
		for (i = 0; i < 1280; i++) {
			ddr_addr[j * 1280 + i] = j << 8 /* green */ | i << 16 /* blue */;
		}
	}

#ifdef TEST_FIFO

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
	hdmi_addr[0] = 1 << 2 | (1 << 0);

	write_val = (0 << 2) /* restart */| (1 << 3) /* start */| (1280 << 4) /* set line_stride */| (4 << 24) /* 4 bytes per pixel */;

	hdmi_addr[0] = write_val; // start FSM, it should now trigger the first read of 64 pixels.

	while (!hdmi_offset_addr[0] & 0x100)
		; // poll done signal
	hdmi_offset_addr[0] &= ~0x100; // reset done

	printf("Last read: %x FIFO head: %x DDR address: %x\n\r", hdmi_addr[0],
			hdmi_addr[1], hdmi_addr[2]);

	write_val ^= (1 << 29); // hsync

	hdmi_addr[0] = write_val; // start FSM, it should now trigger the first read of 64 pixels.

	while (!hdmi_offset_addr[0] & 0x100)
		; // poll done signal
	hdmi_offset_addr[0] &= ~0x100; // reset done

	printf("Last read: %x FIFO head: %x DDR address: %x\n\r", hdmi_addr[0],
			hdmi_addr[1], hdmi_addr[2]);

	write_val ^= (1 << 29); // hsync

	hdmi_addr[0] = write_val; // start FSM, it should now trigger the first read of 64 pixels.

	while (!hdmi_offset_addr[0] & 0x100)
		; // poll done signal
	hdmi_offset_addr[0] &= ~0x100; // reset done

	printf("Last read: %x FIFO head: %x DDR address: %x\n\r", hdmi_addr[0],
			hdmi_addr[1], hdmi_addr[2]);

#endif

#ifdef TEST_SYSTEM
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
	hdmi_addr[0] = 1 << 2 | (1 << 0);

	write_val = (1 << 1) | (0 << 2) /* restart */| (0 << 3)
	/* start */| (1280 << 4) /* set line_stride */| (64 << 14)
	/* pixels per line */| (4 << 24) /* 4 bytes per pixel */;

	hdmi_addr[0] = write_val; // start FSM, it should now trigger the first read of 64 pixels.
#endif

	printf("Exiting\n\r");

	return 0;
}
