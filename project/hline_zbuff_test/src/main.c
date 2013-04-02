#include <stdio.h>
#include <stdbool.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xutil.h"

#define printf xil_printf   /* a smaller footprint printf */
#define HLINE_TEST
#define LENGTH 256 //multiple of 256, up to the size of buffer regions (BUF_SIZE)
#define BUF_SIZE 1024

int main ()
{
	volatile unsigned int * fbuff = (volatile unsigned int *)0xAB000000;
	volatile unsigned int * zbuff = fbuff + BUF_SIZE;

	int i = 0;
	while (i < BUF_SIZE) {
		fbuff[i] = i;
		zbuff[i] = 0xffffffff-i;
		i++;
	}

	volatile int * hline_pcore = (int *)XPAR_HLINE_ZBUFF_0_BASEADDR;
	char * hline_offset = (char *)(hline_pcore + 64);

	hline_pcore[0] = (int)(fbuff + 3);
	hline_pcore[1] = (int)(zbuff);
	hline_pcore[2] = 500; //dx
	hline_pcore[3] = 0;  //z1
	hline_pcore[4] = 1; //slope
	hline_pcore[5] = 0xbeefbeef; //rgbx
	hline_pcore[6] = 0; //error
	hline_pcore[7] = 0; //remainder


	volatile char * debug = (char *)(hline_pcore + 10);
	printf("curr_state: %x | ", debug[0]);
	printf("started: %x | ", debug[1]);
	printf("mst_cmd_sm_wr_req: %x || ", debug[2]);
	printf("mst_sm_state: %x | ", debug[3]);

	printf("status reg: %x | ", hline_offset[1]);
	printf("z_fifo_in: %x | ", hline_pcore[8]);
	printf("f_fifo_in: %d | ", hline_pcore[9]);
	printf("ip2bus_mstwr_d: %x | ", hline_pcore[2]);
	printf("addr: %x\n\r", hline_pcore[11]);

	getchar();
	// start the pcore
	hline_pcore[11] = 1;

	// poll for completeness
	while (hline_pcore[7] == 0);

	printf("curr_state: %x | ", debug[0]);
	printf("started: %x | ", debug[1]);
	printf("mst_cmd_sm_wr_req: %x || ", debug[2]);
	printf("mst_sm_state: %x | ", debug[3]);

	printf("status reg: %x | ", hline_offset[1]);
	printf("z_fifo_in: %x | ", hline_pcore[8]);
	printf("f_fifo_in: %x | ", hline_pcore[9]);
	printf("ip2bus_mstwr_d: %x | ", hline_pcore[2]);
	printf("addr: %x\n\r", hline_pcore[11]);

	printf("hline_zbuff test complete!\r\n");
	return 0;
}

