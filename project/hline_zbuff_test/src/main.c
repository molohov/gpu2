#include <stdio.h>
#include <stdbool.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xutil.h"

#define printf xil_printf   /* a smaller footprint printf */

int main ()
{
	volatile int * hline_pcore = (int *)XPAR_HLINE_ZBUFF_0_BASEADDR;
	char * hline_offset = (char *)(hline_pcore + 64);
	volatile unsigned int * fbuff = (volatile unsigned int *)0xAB000000;
	volatile unsigned int * zbuff = fbuff + 1024;

	printf("%x, %x\n\r", (int)fbuff, (int)zbuff);

	int i = 0;
	while (i < 256) {
		fbuff[i] = i;
		zbuff[i] = 0xffffffff-i;
		i++;
	}

	hline_pcore[0] = (int)fbuff;
	hline_pcore[1] = (int)zbuff;
	hline_pcore[2] = 256; //dx
	hline_pcore[3] = 0;  //z1
	hline_pcore[4] = 0x00ffffff; //slope
	hline_pcore[5] = 0xdeadbeef; //rgbx
	hline_pcore[6] = 128; //error
	hline_pcore[7] = 255; //remainder
	// start it

	hline_pcore[11] = 1;

	volatile char * debug = (char *)(hline_pcore + 9);
	printf("fifo head: %x  | ", hline_pcore[8]);
	printf("curr_state: %x | ", debug[0]);
	printf("zempty: %x | ", debug[1]);
	printf("started: %x || ", debug[2]);

	printf("status reg: %x | ", hline_offset[1]);
	printf("bus2ip_mstrd: %x | ", hline_pcore[0]);
	printf("mst_fifo_valid: %x | ", hline_pcore[1]);
	printf("ip2bus_mstwr: %x\n\r", hline_pcore[2]);
	return 0;
}
