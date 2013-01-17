/*
 * Define the register addresses for the UofT 68000 UltraGizmo board
 */

/* Serial Module Addresses */

#define DUMRAR  0xfffff7e1     /* mode register a read	*/
#define DUMRAW  DUMRAR         /* mode register a write	*/
#define DUSRA   DUMRAR+2       /* status register a	*/
#define DUCSRA  DUMRAR+2       /* clock select register a	*/
#define DUCRA   DUMRAR+4       /* command register a	*/
#define DURBA   DUMRAR+6       /* receive buffer a	*/
#define DUTBA   DUMRAR+6       /* transmit buffer a	*/
#define DUIPCR  DUMRAR+8       /* input port change register	*/
#define DUACR   DUMRAR+8       /* auxiliary control register	*/
#define DUISR   DUMRAR+0xa       /* interupt status register	*/
#define DUIMR   DUMRAR+0xa       /* interupt mask regisster	*/
#define CNTRMSB  DUMRAR+0xc      /* counter most significant byte	*/
#define CNTRUR  DUMRAR+0xc       /* counter/timer upper register	*/
#define CNTRLSB  DUMRAR+0xe      /* counter least significant byte	*/
#define CNTRLR  DUMRAR+0xe       /* counter/timer lower register	*/
#define DUMRBR  0xfffff7f1       /* mode register b read	*/
#define DUMRBW  DUMRBR       /* mode register b write	*/
#define DUSRB   DUMRBR+2       /* status register b	*/
#define DUCSRB  DUMRBR+2       /* clock select register b	*/
#define DUCRB   DUMRBR+4       /* command register b	*/
#define DURBB   DUMRBR+6       /* receive buffer b	*/
#define DUTBE   DUMRBR+6       /* transmit buffer b	*/
#define DUIVRR  DUMRBR+8       /* interrupt vector register read	*/
#define DUIVRW  DUMRBR+8       /* interrupt vector register write	*/
#define DUIP    DUMRBR+0xa       /* input port register	*/
#define DUOPCR  DUMRBR+0xa       /* output port configuration register	*/
#define CNTRSTART  DUMRBR+0xc    /* start counter command	*/
#define DUOPSET  DUMRBR+0xc     /* output port bit set	*/
#define CNTRSTOP  DUMRBR+0xe     /* stop counter command	*/
#define DUOPRESET  DUMRBR+0xe	/* output port bit reset	*/



