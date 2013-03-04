EXE=prototype
CFLAG=-std=c99 -O3 -lm `pkg-config --cflags --libs opencv` -D SW

all: $(EXE)

display.o: display.c display.h
	$(CC) -c display.c $(CFLAG)

gp.o: gp.c gp.h display.h
	$(CC) -c gp.c $(CFLAG)

$(EXE): main.c gp.h gp.o display.o
	$(CC) main.c gp.o display.o $(CFLAG) -o $(EXE)

clean:
	rm -rf $(EXE) *.o

.PHONY: all clean
