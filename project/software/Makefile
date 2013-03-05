EXES=prototype line tri
CFLAG=-g -std=c99 -Os -lm `pkg-config --cflags --libs opencv` -D SW
PROFFLAG=$(CFLAG) -pg -DGP_DISPLAY_TIMEOUT_IN_MS=5
TARGET=main.c
LINE=line.c
TRI=triangle.c
PROF=prof.c

all: $(EXES)

display.o: display.c display.h
	$(CC) -c display.c $(CFLAG)

gp.o: gp.c gp.h display.h
	$(CC) -c gp.c $(CFLAG)

prototype: $(TARGET) gp.h gp.o display.o
	$(CC) $(TARGET) gp.o display.o $(CFLAG) -o $@

line: $(LINE) gp.h gp.o display.o
	$(CC) $(LINE) gp.o display.o $(CFLAG) -o $@

tri: $(TRI) gp.h gp.o display.o
	$(CC) $(TRI) gp.o display.o $(CFLAG) -o $@

prof: $(PROF) gp.h display.h gp.c display.c
	$(CC) $(PROF) gp.c display.c $(PROFFLAG) -o $@
	./$@
	gprof $@ > gprof.out

clean:
	rm -rf $(EXES) prof *.o gmon.out gprof.out

.PHONY: all clean
