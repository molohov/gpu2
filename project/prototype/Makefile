EXE=prototype
CFLAG=-std=c99 -O3 -lm `pkg-config --cflags --libs opencv`

all: $(EXE)

gp.o: gp.c gp.h
	$(CC) -c gp.c $(CFLAG)

$(EXE): main.c gp.h gp.o
	$(CC) main.c gp.o $(CFLAG) -o $(EXE)

clean:
	rm -rf $(EXE) *.o

.PHONY: all clean
