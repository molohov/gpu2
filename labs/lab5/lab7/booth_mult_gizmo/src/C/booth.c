/*
 * Paul Chow
 * November 5, 2004
 * University of Toronto
 *
 * $Id: booth.c,v 1.4 2004/11/10 15:26:17 pc Exp pc $
 *
 * This program demonstrates the use of interrupts with a
 * C language interface for the Booth multiplier.
 * The program was run through lint.
 *
 * Several different ways of accessing memory locations and registers
 * are used.
 *
 * Page numbers refer to the 68306 User's manual
 *
 */

#include <stdio.h>
#include "mapgizmo.h"


/* CFPGA Registers */

#define CFPGA_ICR	0x00c20000    /* configuration register	            */
#define CFPGA_IVR	0x00c20002    /* not needed here for autovectoring */
#define CFPGA_ISR	0x00c20006    /* Interrupt status register	    */


/* 68306 interrupt controller registers and constants */

#define M68K_PDATA	0xfffffff0	/* Port data register, p. 5-3      */
#define M68K_PDIR	0xfffffff2	/* Port direction register p. 5-3  */
#define M68K_ICR	0xfffffffa	/* Interrupt control register. 5-5 */

#define AUTOVEC6	30	/* Level 6 Interrupt autovector, p. 4-16 */


/* Bit masks for the multiplier registers */

#define B_INTBIT	0x8000	/* interrupt enable bit		 */
#define B_RESET		0x2	/* status reg bit mask for Reset */
#define B_GO		0x1	/* status reg bit mask for Go    */


/* The following three procedures are defined in cint.S */

extern int intrstub(void);	    /* links to C interrupt routine */
extern int spl0(void),spl7(void);   /* set priority levels          */

long setvector(int,int (*routine)(void));  /* initializes interrupt vector */

/*
 * This is a structure declaration that allows access to the
 * multipliers registers.
 *
 * Registers          Address
 *
 * Status             16'hA000   Bit 15 Multiplier Done
 *                                      Cleared on read of Product regsiter
 * Interrupt Enable   16'hA002   Bit 15 Enables interrupt on IRQ6 when Done
 *                                      Cleared on read of Product register
 * Multiplier         16'hA004   16 bits Lower byte used as multiplier
 * Multiplicand       16'hA006   16 bits Lower byte used as multiplicand
 * Product            16'hA008   16 bits Contains new result when Done bit set
 * Control            16'hA00A   Bit 1  Reset the multiplier
 *                                      Clears after the reset is sent
 *                               Bit 0  Tells multiplier to start (Go)
 *                                      Cleared on read of Product register
 */

struct booth_multiplier {
  short status;
  short intenable;
  short multiplier;
  short multiplicand;
  short product;
  short control;
};
  
struct booth_multiplier *booth;	/* declare a pointer to the multiplier */

short done;	/* a flag set by interrupt handler */

int main(void)
{
  short dum;
  short imand,imer,oproduct;
  short goterror;

  /* Initialize the pointer to the multiplier base address */
  booth = (struct booth_multiplier *) 0xa00000;

  spl7();  /* Make sure CPU ignores the interrupts for now */

  booth->control |= B_RESET;    /* reset the multiplier */

  /* Do an example by polling first */

  (void) printf("Starting with polling...\n");

  booth->multiplier = 2;
  booth->multiplicand = 0x46;
  booth->control |= B_GO;	/* go! */

  while(booth->status == 0);	/* wait for done */

  (void) printf("In hex: 0x%hx times 0x%hx = 0x%hx\n",booth->multiplier,
		booth->multiplicand, booth->product);
  (void) printf("In decimal: %d times %d = %d\n",booth->multiplier,
		booth->multiplicand, booth->product);
  (void) printf("Check result should be %d\n\n",booth->multiplier *
		booth->multiplicand);

  (void) printf("Now test all the numbers...\n\n");
  goterror = 0;

  for (imer = -128; imer < 128; imer++)
    {
      booth->multiplier = imer;

      for (imand = -128; imand < 128; imand++)
	{
	  booth->multiplicand = imand;
	  booth->control |= B_GO;	/* go! */

	  while(booth->status == 0);	/* wait for done */

	  oproduct = booth->product;

	  if (oproduct != (imer * imand))
	    {
	      (void) printf("Bad result = %d * %d:  Got %d,"
			   " should be %d\n\n",imer,imand,oproduct,imer*imand);
	      goterror = 1;
	    }
	}
    }

  if (!goterror)
      (void) printf("No errors!\n\n");

  (void) printf("Now do it with interrupts\n");

  /* Set up the interrupts */

  dum = *(short *)(CFPGA_ISR);	/* read to clear pending interrupts */

  /* Enable Level 6 for autovectoring, leaves Level 7 for NMI on */
  *(short *)(M68K_ICR) |= 0x2020;

  *(short *)(M68K_PDIR) = 0;		/* not likely necessary	 */
  *(short *)(M68K_PDATA) = 0xffff;	/* no IACKs needed	 */
  *(char *)(CFPGA_ICR) = 0x2;		/* Table 6 in Gizmo manual */
  (void) setvector(AUTOVEC6, intrstub);	/* init interrupt vector */
  spl0();	/* Set processor priority to 0 so it listens to interrupts*/
  booth->intenable = (short) B_INTBIT;	/* turn on interrupts in multiplier */

  /* Input some numbers */

  booth->multiplier = (short) 0x10;
  booth->multiplicand = (short) 0xffad;	/* ffad */
  booth->control |= B_GO;	/* go! */

  done = 0;		/* interrupt routine sets this to 1 */
  while(!done);

  (void) printf("In hex: 0x%hx times 0x%hx = 0x%hx\n",booth->multiplier,
		booth->multiplicand, booth->product);
  (void) printf("In decimal: %d times %d = %d\n",booth->multiplier,
		booth->multiplicand, booth->product);
  (void) printf("Check result should be %d\n\n",booth->multiplier *
		booth->multiplicand);

  (void) printf("Program done\n");

}


long
setvector(int vectornum, int (*routine)(void))
	{
	long oldval;

	oldval = *((long *) (vectornum*sizeof(long)));
	*((long *) (vectornum*sizeof(long))) = (long) routine;
	return(oldval);
	}



/* This is the interrupt service routine linked via intrstub */

int
interrupt()
{
  short dum;

  (void) printf("Interrupt received\n\n");
  dum = booth->product;		/* read result - clears IRQ from multiplier */
  dum = *(short *)(CFPGA_ISR);	/* read to clear pending interrupts */

  done = 1;	/* We are done */
  return(done);
}


