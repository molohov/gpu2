/*
 * crt0.S -- startup file for m68k-coff
 *
 * Copyright (c) 1995 Cygnus Support
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */

#include "asm.h"

	.title "crt0.S for m68k-coff"

/*
 * Define an empty environment.
 */
        .data
        .align 2
SYM (environ):
        .long 0

 	.align	2
	.text
	.global SYM (main)
	.global SYM (exit)


/* 
 * these values are set in the linker script, so they must be
 * explicitly named here with the SYM().
 */
	.global __stack
	.global __bss_start
	.global SYM(_end)

/*
 * start -- set things up so the application will run.
 */
SYM (start):
	/* set up stack pointer */	
/*	moveal  IMM(__stack), sp */
	moveal  IMM(SYM(start)), sp

	/* set up initial stack frame */
	link	a6, IMM(-8)

/*
 * zerobss -- zero out the bss section
 */
	movel	IMM(__bss_start), d1
	movel	IMM(SYM(_end)), d0
	cmpl	d0,d1
	jbeq	2f
	movl	d1,a0
	subl	d1,d0
1:
	clrb	(a0)+
	dbra	d0,1b
	clrw	d0
	subql	IMM(1),d0
	jbcc	1b
2:

/*
 * call the main routine from the application to get it going.
 * main (argc, argv, environ)
 * we pass argv as a pointer to NULL.
 */
        pea     0
        pea     SYM (environ)
        pea     sp@(4)
        pea     0
	jsr	SYM (main)
	movel	d0, sp@-

/*
 * drop down into exit incase the user doesn't. This should drop
 * control back to the ROM monitor, if there is one.
 */
        jsr     SYM (exit)


