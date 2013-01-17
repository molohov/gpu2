* 
* 68K assembly language program to use the Booth multiplier
* 
* Paul Chow
* November 1, 2004
* 
* $Id: booth.s,v 1.4 2004/11/04 14:26:19 pc Exp pc $
* 
* This is an example of a 68K assembly language program that is
* interrupt driven.  To see the definitions and usage of the multiplier
* registers, see the source for bus_controller.v.
*
* The controller is implemented in the FPGA and interrupts on IRQ6.
* 
* This is not a full test of the features of the interface.
*


* Booth multiplier register addresses and constants

B_STATUS	equ	$a00000	; Status register
B_INTENABLE	equ	$a00002	; Interrupt enable register
B_MULTIPLIER	equ	$a00004 ; Multiplier register - need only bottom byte
B_MULTIPLICAND	equ	$a00006 ; Multiplicand register - need only bottom byte
B_PRODUCT	equ	$a00008	; Product register
B_CONTROL	equ	$a0000a ; Control register

B_INTBIT	equ	$8000	; interrupt enable bit
B_RESET		equ	$2	; status reg bit mask for Reset
B_GO		equ	$1	; status reg bit mask for Go

* CFPGA registers

CFPGA_ICR	equ	$00c20000	; configuration register
CFPGA_IVR	equ	$00c20002	; not needed here for auto-vectoring
CFPGA_ISR	equ	$00c20006	; Interrupt status register


* 68306 interrupt controller registers

M68K_PDATA	equ	$fffffff0	; Port data register
M68K_PDIR	equ	$fffffff2	; Port direction register
M68K_ICR	equ	$fffffffa	; Interrupt control register


* Console port DUART registers
* Assume that the DUART is otherwise properly configured

DUART_SRB 	equ 	$fffff7f3	; Status register
DUART_RBB 	equ 	$fffff7f7	; Receive buffer
DUART_TBB 	equ 	$fffff7f7	; Transmit buffer

DUART_RRDY	equ	$0		; Receiver ready bit number
DUART_TRDY	equ	$2		; Transmit ready bit number

* Other constants

CR	equ	$0d			; carriage return
LF	equ	$0a			; line feed
NULL	equ	0			; null character
AUTOVEC6	equ	$78		; Autovector 6


 	org $20000

start	movea.l	#start,a7	; init stack pointer always!

* Start by just doing polling

	move.w	#$2700, sr	; set priority 7 for now to ignore interrupts

	movea.l	#str_start,a0	; print start message
	jsr	putstr
	move.w	#$2,B_MULTIPLIER	; load data
	move.w	#$46,B_MULTIPLICAND	; 2 x 46
	ori.w	#B_GO,B_CONTROL	; go!
tstdone	cmp.w	#0,B_STATUS	; wait for done
	bgt	tstdone
	move.w	B_MULTIPLIER,d0	; print the result
	jsr	puthexb
	movea.l	#str_times,a0
	jsr	putstr
	move.w	B_MULTIPLICAND,d0
	jsr	puthexb
	movea.l	#str_eq,a0
	jsr	putstr	
	move.w	B_PRODUCT,d0	; get result = 8c
	jsr	puthex
	movea.l	#str_nl,a0
	jsr	putstr

* Now do it with interrupts

	movea.l	#str_int,a0
	jsr	putstr

* Set up the interrupts

	move.w	CFPGA_ISR, d0		; read to clear pending interrupts
*					; should not need to, but just in case
	ori.w	#$2020,M68K_ICR		; Enable Interrupt 6, autovectoring
*					; Must leave Level 7 for NMI on
	move.w	#$00, M68K_PDIR		; Probably don't need this line
	move.w	#$ffff, M68K_PDATA	; No IACK required for autovectoring
	move.b	#$2, CFPGA_ICR		; According to Table 6 in gizmo manual
 	move.l	#inthdlr,AUTOVEC6 	; init interrupt vector table
	move.w	#$2000, sr	; set priority 0 to listen to all interrupts
	ori.w	#B_INTBIT,B_INTENABLE	; enable interrupts from multiplier

* Input some numbers

	move.w	#$10,B_MULTIPLIER	; load data
	move.w	#$ad,B_MULTIPLICAND	; $10 x $ad = $fad0
	ori.w	#B_GO,B_CONTROL		; go!
wait	bra	wait			; busy wait for interrupt
prnt	
	move.w	B_MULTIPLIER,d0		; print the inputs
	jsr	puthexb
	movea.l	#str_times,a0
	jsr	putstr
	move.w	B_MULTIPLICAND,d0
	jsr	puthexb
	movea.l	#str_eq,a0
	jsr	putstr	
	move.w	B_PRODUCT,d0		; get result and print it
	jsr	puthex	
	movea.l	#str_nl,a0
	jsr	putstr
	movea.l	#str_done,a0
	jsr	putstr
end	trap	#15			;Exit the program


* Interrupt routine for multiplier

inthdlr
	movea.l	#str_hdlr,a0		
	jsr	putstr
	move.w	B_PRODUCT,d0	; get result - clears IRQ from multiplier
	move.w	CFPGA_ISR,d0	; read to clear interrupt from CFPGA

* This next bit is some trickiness to get out of the wait loop.
* Modify the return PC, currently next to the top of the stack to
* the next instruction after the wait loop.  Note that the saved SR
* is on the top.

	movea.l	#prnt,2(a7)
	rte


* Character handling routines using polling
*
* d0 and a0 are used to pass parameters
*
* putstr outputs a string of characters terminated by
*    a NULL.  A pointer to the string is passed in a0.
* putch outputs a character.
*    The character is passed in d0.
* puthex prints the word contents of d0 in hex on the terminal
* puthexb prints the byte contents of d0 in hex on the terminal

putstr	move.b	(a0)+,d0	; put character in d0
	tst.b	d0		; check for null character
	beq	donestr
	bsr	putch		; print the character
	bra	putstr
donestr	rts

putch   btst.b	#DUART_TRDY,DUART_SRB 	; transmitter ready?
	beq	putch
	move.b	d0,DUART_TBB	; output the character
	rts

puthex	movem.w	d1-d2,-(a7)	; save some regs
	move.w	d0,d1		; free d0 for subroutine calls
	moveq	#3,d2		; counter
nextn	rol.w	#4,d1		; 4 msb in lower nibble
	move.w	d1,d0		; work on d0
	andi.w	#$f,d0		; mask
	cmpi.w	#9,d0		; check if digit 0-9
	bgt	let		; if not, check if A-F
	addi.w	#'0',d0		; convert to ASCII digit
	jsr	putch
	dbeq	d2,nextn	; check if done
	bra	lastch
let	subi.w	#10,d0		; letter offset
	addi.w	#'a',d0		; convert to ASCII letter
	jsr putch		; output the character
	dbeq	d2,nextn	; check if done
lastch	movem.w	(a7)+,d1-d2	; restore regs
	rts

puthexb	movem.w	d1-d2,-(a7)	; save some regs
	move.w	d0,d1		; free d0 for subroutine calls
	moveq	#1,d2		; counter
nextnb	rol.b	#4,d1		; 4 msb in lower nibble
	move.w	d1,d0		; work on d0
	andi.w	#$f,d0		; mask
	cmpi.w	#9,d0		; check if digit 0-9
	bgt	letb		; if not, check if A-F
	addi.w	#'0',d0		; convert to ASCII digit
	jsr	putch
	dbeq	d2,nextnb	; check if done
	bra	lastchb
letb	subi.w	#10,d0		; letter offset
	addi.w	#'a',d0		; convert to ASCII letter
	jsr putch		; output the character
	dbeq	d2,nextn	; check if done
lastchb	movem.w	(a7)+,d1-d2	; restore regs
	rts


* string definitions
* all strings are NULL terminated

str_done	dc.b	CR,LF,'Program done'
str_nl		dc.b	CR,LF,NULL

str_start	dc.b	CR,LF,'Starting with polling...',CR,LF,NULL
str_times	dc.b	' times ',NULL
str_eq		dc.b	' = ',NULL
str_int		dc.b	CR,LF,'Test by interrupts',CR,LF,NULL
str_hdlr	dc.b	CR,LF,'Interrupt received',CR,LF,NULL


