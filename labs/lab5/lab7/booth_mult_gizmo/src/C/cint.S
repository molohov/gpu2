
/*
 * Routines required for doing interrupts from a C program.
 *
 * Paul Chow (c) 1999
 */

	#include "asm.h"

        .title "cint.S for m68k-coff"


	.global SYM (intrstub)
	.global SYM (interrupt)
	.global SYM (spl0)
	.global SYM (spl7)

/*
 * This is the routine pointed at by the interrupt vector location.
 * Load it at the interrupt vector.  It saves the registers not saved by C
 * and then calls the C routine called interrupt to process the interrupt.
 * Upon return from C, the registers are restored, and an rte is executed.
 */

SYM (intrstub):
        moveml  d0/d1/a0/a1,sp@-
        jsr     SYM (interrupt)
        moveml  sp@+,d0/d1/a0/a1
        rte

SYM (spl0):
        movw    sr,d0
        movw    #0x2000,sr
        rts

SYM (spl7):
        movw    sr,d0
        movw    #0x2700,sr
        rts
