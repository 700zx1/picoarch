#include "buffer.h"
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "scale.h"

// Externs for shared buffer/scaler structs (must be defined by platform)
extern struct GFX_Buffer buffer;
extern struct GFX_Scaler scaler;
extern double aspect_ratio;
extern enum scale_size scale_size;

// Weak declarations for platform-specific helpers
__attribute__((weak)) void buffer_renew_surface(unsigned w, unsigned h, size_t pitch) {}
__attribute__((weak)) void buffer_clear(void) {}
__attribute__((weak)) void buffer_quit_platform(void) {}

void buffer_init(void) {
    buffer.width  = 1280;
    buffer.height = 960;
    buffer.depth  = 16;
    buffer.pitch  = buffer.width * SCREEN_BPP;
    buffer.size = buffer.pitch * buffer.height;
    // Memory allocation and initialization logic here
}

void buffer_scale(unsigned w, unsigned h, size_t pitch, const void *src) {
    bool update_asp = false;
    if (w!=scaler.src_w || h!=scaler.src_h || pitch!=scaler.src_p) {
        if (buffer_renew_surface) buffer_renew_surface(w,h,pitch);
        update_asp = true;
    }
    static int scaler_mode;
    if (scaler_mode!=scale_size) {
        scaler_mode = scale_size;
        update_asp = true;
    }
    if (update_asp) {
        printf("update aspect ratio\n"); fflush(stdout);
        if (buffer_clear) buffer_clear();
        if (aspect_ratio<=0) aspect_ratio = (float)scaler.src_w / scaler.src_h;
        if (scale_size==SCALE_SIZE_ASPECT) {
            scaler.asp_w = SCREEN_HEIGHT * aspect_ratio;
            scaler.asp_h = (int)(SCREEN_HEIGHT + 0.5f);
            if (scaler.asp_w>SCREEN_WIDTH) {
                scaler.asp_w = SCREEN_WIDTH;
                scaler.asp_h = (int)(SCREEN_WIDTH / aspect_ratio + 0.5f);
            }
            scaler.asp_x = (SCREEN_WIDTH - scaler.asp_w) / 2;
        }
    }
    // Scaling logic here
}

void buffer_quit(void) {
    if (buffer_quit_platform) buffer_quit_platform();
    if (buffer.phyAddr) {
        // Freeing logic here
    }
}
