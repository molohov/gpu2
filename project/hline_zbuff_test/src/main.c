#include <stdio.h>
#include <stdbool.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xutil.h"

#define printf xil_printf   /* a smaller footprint printf */
#define BURST_TEST

int main ()
{
	volatile unsigned int * fbuff = (volatile unsigned int *)0xAB000000;
	volatile unsigned int * zbuff = fbuff + 1024;

	int i = 0;
	while (i < 256) {
		fbuff[i] = i;
		zbuff[i] = 0xffffffff-i;
		i++;
	}

#ifdef BURST_TEST
	volatile unsigned int * burst_write_addr = (unsigned int *)XPAR_BURST_WRITE_0_BASEADDR;

	// burst read
	burst_write_addr[64] = 1 | (1 << 3); // burst read
	burst_write_addr[65] = 0xab000000; //address
	burst_write_addr[66] = 0xffff; // byte enable
    burst_write_addr[67] = 0x0a000000 | 16 * 4; // go and length (16 words)
    while (!(burst_write_addr[64] & 0x100)) {
      }
    burst_write_addr[64] &= ~0x100;
    printf("read complete!\n\r");

	// burst write
	burst_write_addr[0] = 0xdeadbeef; //write value
	burst_write_addr[64] = (1 << 1) | (1 << 3); // burst write
	burst_write_addr[65] = 0xab000000; // address
    burst_write_addr[66] = 0xffff; // byte enable
    burst_write_addr[67] = 0x0a000000 | 16 * 4; // go and length (16 words)
    while (!(burst_write_addr[64] & 0x100)) {
      }
    // clear done bit
    burst_write_addr[64] &= ~0x100;
    printf("write complete!\n\r");
#endif

#ifdef HLINE_TEST
	volatile int * hline_pcore = (int *)XPAR_HLINE_ZBUFF_0_BASEADDR;
	char * hline_offset = (char *)(hline_pcore + 64);


	hline_pcore[0] = (int)fbuff;
	hline_pcore[1] = (int)(zbuff);
	hline_pcore[2] = 256; //dx
	hline_pcore[3] = 0;  //z1
	hline_pcore[4] = 0x00ffffff; //slope
	hline_pcore[5] = 0xdeadbeef; //rgbx
	hline_pcore[6] = 128; //error
	hline_pcore[7] = 255; //remainder
	// start it

	hline_pcore[11] = 1;

	// poll for completeness
	// while (hline_pcore[7] == 0);
	volatile int j = 0;
	while (j < 2048)
		j++;

	//while (1) {
	volatile char * debug = (char *)(hline_pcore + 10);
	printf("curr_state: %x | ", debug[0]);
	printf("mst_cmd_sm_rd_req: %x | ", debug[1]);
	printf("mst_cmd_sm_wr_req: %x || ", debug[2]);
	printf("mst_sm_state: %x | ", debug[3]);

	printf("status reg: %x | ", hline_offset[1]);
	printf("z_fifo_in: %x | ", hline_pcore[8]);
	printf("f_fifo_in: %d | ", hline_pcore[9]);
	printf("ip2bus_mstwr_d: %x | ", hline_pcore[2]);
	printf("addr: %x\n\r", hline_pcore[11]);
	//}
#endif
	return 0;
}

