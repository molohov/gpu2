/*
 * main.c
 *
 *  Created on: Jan 24, 2013
 *      Author: Victor Zhang
 */

#include <stdio.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xutil.h"

#define printf xil_printf   /* a smaller footprint printf */
#define NUM_TEST_WORDS 8
#define TEST_VECTOR 0x12345678 /* random word */

int main() {
	volatile u32 *ddr_addr = (volatile u32 *) XPAR_S6DDR_0_S0_AXI_BASEADDR;
	printf("32-bit test: %s\n\r",
			(XST_SUCCESS == XUtil_MemoryTest32(ddr_addr, NUM_TEST_WORDS,
					TEST_VECTOR, XUT_ALLMEMTESTS)) ? "passed" : "failed");

	volatile int *hdmi_addr = (int *)XPAR_HDMI_OUT_0_BASEADDR;

#define TEST_DDR

#ifdef TEST_DDR
	volatile int *hdmi_offset_addr = hdmi_addr + 0x40;

	int i;
	for (i = 0; i < 1024; i++) {
		ddr_addr[i] = 0xdead0000 | i;
	}

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
	printf("sync: %x\n\r", hdmi_addr[2]);

	hdmi_addr[0] = 1; // reset
	hdmi_addr[1] = 0x00ff8811; // write 1188ff (RGB) as the colour
	hdmi_addr[0] = 2; // GO!

	printf("sync: %x\n\r", hdmi_addr[2]);

	while (1) {
		char get = (char)*(volatile int *)(XPAR_RS232_UART_1_BASEADDR);
		if (get != 0)
			break;
	}

	printf("sync: %x\n\r", hdmi_addr[2]);

	hdmi_addr[0] = 1;
#endif

	printf("Exiting\n\r");

	return 0;
}
