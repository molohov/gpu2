EXE=prototype
CFLAG=-std=c99 -Os -lm `pkg-config --cflags --libs opencv` -D SW
PROFFLAG=$(CFLAG) -g -pg -DGP_DISPLAY_TIMEOUT_IN_MS=1
TARGET=main.c

all: $(EXE)

display.o: display.c display.h
	$(CC) -c display.c $(CFLAG)

gp.o: gp.c gp.h display.h
	$(CC) -c gp.c $(CFLAG)

$(EXE): $(TARGET) gp.h gp.o display.o
	$(CC) $(TARGET) gp.o display.o $(CFLAG) -o $(EXE)

prof: $(TARGET) gp.h gp.o display.o
	$(CC) -c display.c $(PROFFLAG)
	$(CC) -c gp.c $(PROFFLAG)
	$(CC) $(TARGET) gp.o display.o $(PROFFLAG) -o $(EXE)
	./$(EXE)
	gprof $(EXE) > gprof.out

clean:
	rm -rf $(EXE) *.o gmon.out gprof.out

.PHONY: all prof clean
