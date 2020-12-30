# ============================= target: all =============================

CC = gcc

LDFLAGS = `pkg-config --libs sdl2` -lm -latomic -ldl -lpthread -O3 -flto -fomit-frame-pointer

CFLAGS = -Wall -Wextra -Werror -pedantic -std=c11 -c `pkg-config --cflags sdl2` -O3 -flto -march=native -fomit-frame-pointer

# for macos:
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    CFLAGS += -framework OpenGL
else
	CFLAGS += -lGL
endif

all: pixelflut

pixelflut: main.o
	$(CC) -o pixelflut main.o $(LDFLAGS)

main.o: main.c commandhandler.c framebuffer.c histogram.c server.c
	$(CC) $(CFLAGS) $< -o $@

# ============================= clean =============================

clean:
	rm -rf *.o pixelflut
