EXE=gpu
CFLAG=-O3 `pkg-config --cflags --libs opencv`

all:
	$(CC) main.c $(CFLAG) -o $(EXE)

clean:
	rm -rf $(EXE)
