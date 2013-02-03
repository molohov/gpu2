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

	printf("sync: %x\n\r", hdmi_addr[2]);

	hdmi_addr[0] = 1;
	hdmi_addr[1] = 0x00ff8811;
	hdmi_addr[0] = 2;

	printf("sync: %x\n\r", hdmi_addr[2]);

	while (1) {
		char get = (char)*(volatile int *)(XPAR_RS232_UART_1_BASEADDR);
		if (get != 0)
			break;
	}

	printf("sync: %x\n\r", hdmi_addr[2]);

	hdmi_addr[0] = 1;

	printf("Exiting\n\r");

	return 0;
}
