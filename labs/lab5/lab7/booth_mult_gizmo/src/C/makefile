COMPILE.S=$(CC) $(CFLAGS) $(CPPFLAGS) -c

PROGSTART = 20000

CFLAGS = -mc68000  
LDFLAGS = -lc -lgizmo2 -dc -dp -Ttext ${PROGSTART} -N
CC = m68k-coff-gcc

AS = m68k-coff-as
AR = m68k-coff-ar
LD = m68k-coff-ld
RANLIB = m68k-coff-ranlib

SREC = /local/bin/m68k-coff-objcopy

CRT0 = crt0.o

SRC = booth

${SRC}.srec:	${SRC}
	${SREC} -O srec -S  ${SRC}  ${SRC}.srec

${SRC}: ${CRT0} ${SRC}.o cint.o
	${CC} ${CFLAGS} ${CRT0} ${SRC}.o cint.o -o ${SRC} ${LDFLAGS}

${SRC}.o: ${SRC}.c
	${CC} ${CFLAGS} ${SRC}.c -c

crt0.o: crt0.S

cint.o: cint.S

clean:
	rm -f *.o ${SRC} *.srec

