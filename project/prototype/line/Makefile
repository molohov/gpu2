EXE=line
CFLAG=-std=c99 -O3 -lm `pkg-config --cflags --libs opencv` -D SW #enable these for gprof -g -pg
TARGET=line.c

all: $(EXE)

display.o: display.c display.h
	$(CC) -c display.c $(CFLAG)

gp.o: gp.c gp.h display.h
	$(CC) -c gp.c $(CFLAG)

$(EXE): $(TARGET) gp.h gp.o display.o
	$(CC) $(TARGET) gp.o display.o $(CFLAG) -o $(EXE)

clean:
	rm -rf $(EXE) *.o

.PHONY: all clean
