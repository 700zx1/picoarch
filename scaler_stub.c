// scaler_stub.c - fallback for non-ARM architectures
#include <stdint.h>
#include <stddef.h>
#include "scale.h"
#include "buffer.h"

// Forward declarations for the generic C versions
void scale1x(unsigned w, unsigned h, size_t pitch, const void *src, void *dst);
void scale2x(unsigned w, unsigned h, size_t pitch, const void *src, void *dst);
void scale3x(unsigned w, unsigned h, size_t pitch, const void *src, void *dst);

// Fallback implementations for _n16 functions
#if !defined(__ARM_NEON) && !defined(__aarch64__)
void scale1x_n16(void* src, void* dst, uint32_t sw, uint32_t sh, uint32_t sp, uint32_t dp) {
    scale1x(sw, sh, sp, src, dst);
}
void scale2x_n16(void* src, void* dst, uint32_t sw, uint32_t sh, uint32_t sp, uint32_t dp) {
    scale2x(sw, sh, sp, src, dst);
}
void scale3x_n16(void* src, void* dst, uint32_t sw, uint32_t sh, uint32_t sp, uint32_t dp) {
    scale3x(sw, sh, sp, src, dst);
}
#endif
