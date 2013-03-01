EXES=prototype line tri
CFLAG=-std=c99 -Os -lm `pkg-config --cflags --libs opencv` -D SW
PROFFLAG=$(CFLAG) -g -pg -DGP_DISPLAY_TIMEOUT_IN_MS=1
TARGET=main.c
LINE=line.c
TRI=triangle.c

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

prof: $(TARGET) gp.h display.h gp.c display.c
	$(CC) $(TARGET) gp.c display.c $(PROFFLAG) -o $@
	./$@
	gprof $@ > gprof.out

clean:
	rm -rf $(EXES) prof *.o gmon.out gprof.out

.PHONY: all clean
