EXE=gpu
CFLAG=-std=c99 -O3 `pkg-config --cflags --libs opencv`

all:
	$(CC) main.c $(CFLAG) -o $(EXE)

clean:
	rm -rf $(EXE)
