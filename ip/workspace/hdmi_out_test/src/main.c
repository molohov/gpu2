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

#define TEST_SYSTEM
#define RGB565

int main() {
#ifdef RGB565
	volatile u16 *ddr_addr = (volatile u16 *) XPAR_S6DDR_0_S0_AXI_BASEADDR;
#else
	volatile u32 *ddr_addr = (volatile u32 *) XPAR_S6DDR_0_S0_AXI_BASEADDR;
#endif

	printf(
			"32-bit test: %s\n\r",
			(XST_SUCCESS == XUtil_MemoryTest32((u32 *)ddr_addr, NUM_TEST_WORDS,
					TEST_VECTOR, XUT_ALLMEMTESTS)) ? "passed" : "failed");

	volatile int *hdmi_addr = (int *) XPAR_HDMI_OUT_0_BASEADDR;

	// fill up off-chip memory with known values
#ifdef RGB565
	int i, j;
	for (j = 0; j < 720; j++) {
		for (i = 0; i < 1280; i++) {
			ddr_addr[j * 1280 + i] = (j / 8 % 32) << 11 /* red */ | (i * 25 / 2048 % 64) << 5 /* green */ | (i / 8 % 32) /* blue */;
		}
	}
#else
	int i, j;
	for (j = 0; j < 720; j++) {
		for (i = 0; i < 1280; i++) {
			ddr_addr[j * 1280 + i] = j << 24 /* red */ | (i * 25 / 256) << 16 /* green */ | (i % 256) << 8 /* blue */;
		}
	}
#endif

#ifdef TEST_SYSTEM
	// set stride
	hdmi_addr[0] = 1280; // hdmi_addr[0] corresponds to slv_reg2
	// set frame base address
	hdmi_addr[1] = (int)ddr_addr; // hdmi_addr[1] corresponds to slv_reg1
	// go
	hdmi_addr[2] = 1;

	int k = 0, DELAY = 100;
	while (1)
	{
		for (j = 0; j < 720; j++) {
			for (i = 0; i < 1280; i++) {
				for (k = 0; k < DELAY; k++);
				ddr_addr[j * 1280 + i] = 0xffffffff;
			}
		}

#ifdef RGB565
	int i, j;
	for (j = 0; j < 720; j++) {
		for (i = 0; i < 1280; i++) {
			ddr_addr[j * 1280 + i] = (j / 8 % 32) << 11 /* red */ | (i * 25 / 2048 % 64) << 5 /* green */ | (i / 8 % 32) /* blue */;
		}
	}
#else
	int i, j;
	for (j = 0; j < 720; j++) {
		for (i = 0; i < 1280; i++) {
			ddr_addr[j * 1280 + i] = j << 24 /* red */ | (i * 25 / 256) << 16 /* green */ | (i % 256) << 8 /* blue */;
		}
	}
#endif

	}
#endif

	printf("Exiting\n\r");

	return 0;
}
