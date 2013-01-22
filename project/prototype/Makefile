EXE=prototype
CFLAG=-std=c99 -O3 `pkg-config --cflags --libs opencv`
LFLAG=-lm

all: $(EXE)

gp.o: gp.c gp.h
	$(CC) -c gp.c $(CFLAG)

$(EXE): main.c gp.h gp.o
	$(CC) main.c gp.o $(CFLAG) $(LFLAG) -o $(EXE)

clean:
	rm -rf $(EXE) *.o

.PHONY: all clean
