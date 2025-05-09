#include <SDL/SDL.h>
#include <stdio.h>

int main() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
        return -1;
    }
    printf("SDL initialized successfully.\n");

    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "SDL_Init (audio) failed: %s\n", SDL_GetError());
        return -1;
    }
    printf("SDL audio initialized successfully.\n");

    SDL_Quit();
    return 0;
}
// to compile: gcc -o simple_sdl_test simple_sdl_test.c -lSDL
// to run: ./simple_sdl_test
// to check for memory leaks: valgrind --leak-check=full ./simple_sdl_test