#include <stdio.h>
#include <stdbool.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xutil.h"

#define printf xil_printf   /* a smaller footprint printf */

int main (void)
{
	int * hline_pcore = (int *)XPAR_HLINE_ZBUFF_0_BASEADDR;
	int * fbuff = (int *)0xAC000000;
	int * zbuff = fbuff + 1024;

	int i = 0;
	while (i < 1024) {
		fbuff[i] = 0;
		zbuff[i] = 0xffffffff;
		i++;
	}

	hline_pcore[0] = (int)fbuff;
	hline_pcore[1] = (int)zbuff;
	hline_pcore[2] = 256;
	hline_pcore[3] = 0;
	hline_pcore[4] = 0x00ffffff;
	hline_pcore[5] = 0xdeadbeef;
	hline_pcore[6] = 128;
	hline_pcore[7] = 255;
	// start it

	hline_pcore[11] = 1;

	return 0;
}
