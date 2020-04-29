#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef BUILD_LIBGALVANI
#define GALVANI_API __declspec(dllexport)
#else
#define GALVANI_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ======= High level APIs =======
struct ChannelInfo;
struct GalvaniDevice;

GALVANI_API struct ChannelInfo* GetChannelInfoSquare(int64_t n_pulses, double rising_time, double amp, double pulse_width, double period, double falling_time);
GALVANI_API struct ChannelInfo* GetChannelInfoSine(int64_t n_pulses, double rising_time, double amp, double pulse_width, double period, double falling_time);
GALVANI_API struct ChannelInfo* GetChannelInfoCustom(int64_t n_pulses, const char* wave, size_t wave_len, double sample_rate);
GALVANI_API struct GalvaniDevice* GetGalvaniDevice(const char* dev_name, size_t dev_name_len, uint8_t offset);
GALVANI_API void StartGalvaniDevice(struct GalvaniDevice* gd);
GALVANI_API void StopGalvaniDevice(struct GalvaniDevice* gd);
GALVANI_API void GalvaniDeviceSetChannel(struct GalvaniDevice* gd, int channel, struct ChannelInfo* ci);
GALVANI_API bool GalvaniDeviceGetStatus(struct GalvaniDevice* gd, bool buffer[128]);

// ======= Low level APIs =======
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
