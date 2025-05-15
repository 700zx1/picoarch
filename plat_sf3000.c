#include <SDL/SDL.h>
#include "libretro.h"
#include "libpicofe/plat.h"
#include "libpicofe/input.h"
#include "libpicofe/in_sdl.h"
#include "main.h"
#include "util.h"
#include "scale.h"
#include "scaler_neon.h"
#include "plat.h"

// Video system
static SDL_Surface* screen;
static SDL_Surface* clean_screen;
//static Uint32 video_flags = SDL_SWSURFACE;

// Buffer structure
static struct GFX_Buffer buffer;

// Function prototypes
//void in_sdl_key_down(int key);
//void in_sdl_key_up(int key);

// Initialize the framebuffer buffer
/*
void buffer_init(void) {
    buffer.width = SCREEN_WIDTH;
    buffer.height = SCREEN_HEIGHT;
    buffer.depth = SCREEN_BPP;
    buffer.pitch = buffer.width * (SCREEN_BPP / 8);
    buffer.size = buffer.pitch * buffer.height;

    // Allocate memory for the buffer
    buffer.virAddr = malloc(buffer.size);
    if (!buffer.virAddr) {
        PA_ERROR("Failed to allocate memory for framebuffer\n");
        return;
    }

    // Clear the buffer
    memset(buffer.virAddr, 0, buffer.size);

    PA_INFO("buffer_init() completed for sf3000\n");
}

// Clean up the framebuffer buffer
void buffer_quit(void) {
    if (buffer.virAddr) {
        free(buffer.virAddr);
        buffer.virAddr = NULL;
    }

    buffer.width = 0;
    buffer.height = 0;
    buffer.depth = 0;
    buffer.pitch = 0;
    buffer.size = 0;

    PA_INFO("buffer_quit() completed for sf3000\n");
}

// Scale the source image to the framebuffer
void buffer_scale(int w, int h, int pitch, void *data) {
    SDL_Surface *src_surface = SDL_CreateRGBSurfaceFrom(
        data, w, h, SCREEN_BPP, pitch,
        0x00FF0000,  // Red mask
        0x0000FF00,  // Green mask
        0x000000FF,  // Blue mask
        0xFF000000   // Alpha mask
    );

    if (!src_surface) {
        PA_ERROR("Failed to create source surface: %s\n", SDL_GetError());
        return;
    }

    SDL_Rect dst_rect = { 0, 0, buffer.width, buffer.height };
    if (SDL_BlitSurface(src_surface, NULL, screen, &dst_rect) < 0) {
        PA_ERROR("SDL_BlitSurface failed: %s\n", SDL_GetError());
    }

    SDL_FreeSurface(src_surface);

    if (SDL_Flip(screen) < 0) {
        PA_ERROR("SDL_Flip failed: %s\n", SDL_GetError());
    }
}
*/

// plat_sf3000.c
// Only platform-specific overrides or stubs for sf3000. All common SDL1.2 code is now provided by plat_sdl.c.

// Add platform-specific code here only if needed.

// Input system
static const struct in_default_bind in_sdl_defbinds[] = {
    { SDLK_UP,        IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_UP },
    { SDLK_DOWN,      IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_DOWN },
    { SDLK_LEFT,      IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_LEFT },
    { SDLK_RIGHT,     IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_RIGHT },
    { SDLK_LCTRL,     IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_B },
    { SDLK_SPACE,     IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_A },
    { SDLK_LSHIFT,    IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_X },
    { SDLK_LALT,      IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_Y },
    { SDLK_RETURN,    IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_START },
    { SDLK_RCTRL,     IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_SELECT },
    { SDLK_TAB,       IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_L },
    { SDLK_BACKSPACE, IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_R },
    { SDLK_q,         IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_L2 },
    { SDLK_BACKSLASH, IN_BINDTYPE_PLAYER12, RETRO_DEVICE_ID_JOYPAD_R2 },
    { SDLK_ESCAPE,    IN_BINDTYPE_EMU, EACTION_MENU },
    { 0, 0, 0 }
};

const struct menu_keymap in_sdl_key_map[] =
{
    { SDLK_UP,        PBTN_UP },
    { SDLK_DOWN,      PBTN_DOWN },
    { SDLK_LEFT,      PBTN_LEFT },
    { SDLK_RIGHT,     PBTN_RIGHT },
    { SDLK_SPACE,     PBTN_MOK },
    { SDLK_LCTRL,     PBTN_MBACK },
    { SDLK_LALT,      PBTN_MA2 },
    { SDLK_LSHIFT,    PBTN_MA3 },
    { SDLK_TAB,       PBTN_L },
    { SDLK_BACKSPACE, PBTN_R },
    { SDLK_ESCAPE,    PBTN_MENU },
};

const struct menu_keymap in_sdl_joy_map[] =
{
    { SDLK_UP,    PBTN_UP },
    { SDLK_DOWN,  PBTN_DOWN },
    { SDLK_LEFT,  PBTN_LEFT },
    { SDLK_RIGHT, PBTN_RIGHT },
    { SDLK_WORLD_0, PBTN_MOK },
    { SDLK_WORLD_1, PBTN_MBACK },
    { SDLK_WORLD_2, PBTN_MA2 },
    { SDLK_WORLD_3, PBTN_MA3 },
};

static const char * const in_sdl_key_names[SDLK_LAST] = {
    [SDLK_UP]         = "UP",
    [SDLK_DOWN]       = "DOWN",
    [SDLK_LEFT]       = "LEFT",
    [SDLK_RIGHT]      = "RIGHT",
    [SDLK_LSHIFT]     = "X",
    [SDLK_LCTRL]      = "B",
    [SDLK_SPACE]      = "A",
    [SDLK_LALT]       = "Y",
    [SDLK_RETURN]     = "START",
    [SDLK_RCTRL]      = "SELECT",
    [SDLK_TAB]        = "L",
    [SDLK_BACKSPACE]  = "R",
    [SDLK_1]          = "MENU+UP",
    [SDLK_2]          = "MENU+DOWN",
    [SDLK_3]          = "MENU+LEFT",
    [SDLK_4]          = "MENU+RIGHT",
    [SDLK_5]          = "MENU+B",
    [SDLK_6]          = "MENU+A",
    [SDLK_7]          = "MENU+X",
    [SDLK_8]          = "MENU+Y",
    [SDLK_9]          = "MENU+START",
    [SDLK_0]          = "MENU+SELECT",
    [SDLK_q]          = "MENU+L",
    [SDLK_BACKSLASH]  = "MENU+R",
    [SDLK_ESCAPE]     = "MENU",
};

static const struct mod_keymap in_sdl_mod_keymap[] = {
    { SDLK_UP,        SDLK_1 },
    { SDLK_DOWN,      SDLK_2 },
    { SDLK_LEFT,      SDLK_3 },
    { SDLK_RIGHT,     SDLK_4 },
    { SDLK_LCTRL,     SDLK_5 },
    { SDLK_SPACE,     SDLK_6 },
    { SDLK_LSHIFT,    SDLK_7 },
    { SDLK_LALT,      SDLK_8 },
    { SDLK_RETURN,    SDLK_9 },
    { SDLK_RCTRL,     SDLK_0 },
    { SDLK_TAB,       SDLK_q },          /* mod+L1 = L2 */
    { SDLK_BACKSPACE, SDLK_BACKSLASH },  /* mod+R1 = R2 */
};

static const struct in_pdata in_sdl_platform_data = {
    .defbinds  = in_sdl_defbinds,
    .key_map   = in_sdl_key_map,
    .kmap_size = array_size(in_sdl_key_map),
    .joy_map   = in_sdl_joy_map,
    .jmap_size = array_size(in_sdl_joy_map),
    .key_names = in_sdl_key_names,
    .mod_key      = SDLK_ESCAPE,
    .mod_keymap   = in_sdl_mod_keymap,
    .modmap_size  = array_size(in_sdl_mod_keymap),
};

#include "plat_sdl.c"