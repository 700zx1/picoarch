#include <SDL/SDL.h>
#include <stdio.h>

int main() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Surface *screen = SDL_SetVideoMode(720, 1280, 32, SDL_SWSURFACE);
    if (!screen) {
        printf("SDL_SetVideoMode failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    printf("SDL video initialized successfully!\n");
    SDL_Quit();
    return 0;
}