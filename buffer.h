#ifndef BUFFER_H
#define BUFFER_H

#include <stddef.h>
#include <stdint.h>
#include "scale.h"

// Define scaler type based on platform
#if defined(PLATFORM_SF3000) || defined(PLATFORM_MIPS)
#include "scaler_neon.h"
typedef scale_neon_t scaler_func_t;
#else
#include "scaler_stub.h"
typedef void (*scaler_func_t)(unsigned w, unsigned h, size_t pitch, const void *src, void *dst);
#endif

struct GFX_Buffer {
    uintptr_t phyAddr;
    void* virAddr;
    int width;
    int height;
    int depth;
    int pitch;
    uint32_t size;
};

struct GFX_Scaler {
    scaler_func_t upscale;
    int src_w;
    int src_h;
    int src_p;
    int dst_w;
    int dst_h;
    int dst_p;
    int asp_x;
    int asp_y;
    int asp_w;
    int asp_h;
};

extern struct GFX_Buffer buffer;
extern struct GFX_Scaler scaler;

void buffer_init(void);
void buffer_scale(unsigned w, unsigned h, size_t pitch, const void *src);
void buffer_quit(void);

#endif // BUFFER_H
