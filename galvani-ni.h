#pragma once

#include <stdint.h>

#ifdef BUILD_LIBGALVANI
#define GALVANI_API __declspec(dllexport)
#else
#define GALVANI_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct Galvani;

// Init Galvani from National Instrument digital output device
GALVANI_API struct Galvani* galvani_init_ni(const char* ni_device);

// Set Galvani buffer size. This will affect the delay from computer operation to actual waveform output
// buffer: buffer size in seconds
GALVANI_API void galvani_set_buffer_size(struct Galvani* dev, double buffer);

// Get Galvani buffer size in seconds. Returns 0 on fail.
GALVANI_API double galvani_get_buffer_size(struct Galvani* dev);

// Get number of samples of total buffer
GALVANI_API uint32_t galvani_get_buffer_size_samples(struct Galvani* dev);

// Get number of samples currently in buffer
GALVANI_API uint32_t galvani_get_buffer_samples(struct Galvani* dev);

// Send binary command to galvani
GALVANI_API void galvani_send_command(struct Galvani* dev, const char* command, int32_t command_count);

GALVANI_API void galvani_end(struct Galvani* dev);

#ifdef __cplusplus
}
#endif
