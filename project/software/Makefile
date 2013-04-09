EXES=prototype line zbuff zbuff_dbg wasd sketchup flight
CFLAG=-g -std=c99 -Os -lm `pkg-config --cflags --libs opencv` -D SW
PROFFLAG=$(CFLAG) -pg -DGP_DISPLAY_TIMEOUT_IN_MS=5
TARGET=main.c
LINE=line.c
PROF=prof.c
ZBUFF=zbuff.c
WASD=wasd.c
SKETCHUP=sketchup.c
FLIGHT=flight.c

all: $(EXES)

display.o: display.c display.h
	$(CC) -c display.c $(CFLAG)

gp.o: gp.c gp.h display.h
	$(CC) -c gp.c $(CFLAG)

prototype: $(TARGET) gp.h gp.o display.o
	$(CC) $(TARGET) gp.o display.o $(CFLAG) -o $@

line: $(LINE) gp.h gp.o display.o
	$(CC) $(LINE) gp.o display.o $(CFLAG) -o $@

zbuff: $(ZBUFF) gp.h gp.o display.o
	$(CC) $(ZBUFF) gp.o display.o $(CFLAG) -o $@

zbuff_dbg: $(ZBUFF) gp.h display.h gp.c display.c
	$(CC) $(ZBUFF) gp.c display.c $(CFLAG) -DDISPLAY_Z_BUFFER -o $@

wasd: $(WASD) gp.h gp.o display.h display.c
	$(CC) $(WASD) gp.o display.c -DGP_DISPLAY_TIMEOUT_IN_MS=5 $(CFLAG) -o $@

wasd_prof: $(WASD) gp.h gp.o display.h display.c
	$(CC) $(WASD) gp.c display.c $(PROFFLAG) -o $@
	./$@
	gprof $@ > gprof.out

sketchup: $(SKETCHUP) gp.h gp.o display.h display.c
	$(CC) $(SKETCHUP) gp.o display.c -DGP_DISPLAY_TIMEOUT_IN_MS=5 $(CFLAG) -o $@

flight: $(FLIGHT) gp.h gp.o display.h display.c
	$(CC) $(FLIGHT) gp.o display.c -DGP_DISPLAY_TIMEOUT_IN_MS=5 $(CFLAG) -o $@

prof: $(PROF) gp.h display.h gp.c display.c
	$(CC) $(PROF) gp.c display.c $(PROFFLAG) -o $@
	./$@
	gprof $@ > gprof.out

clean:
	rm -rf $(EXES) prof wasd_prof *.o gmon.out gprof.out

.PHONY: all clean
