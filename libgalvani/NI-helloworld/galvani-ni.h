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

// The API is organized in 2 levels.
// You can use either one set to complete the stimulation task.

// ======= High level APIs =======
struct ChannelInfo;
struct GalvaniDevice;

// Get ChannelInfo from square / trapizoid waveform parameters. amp is represented in control code, and must between 0~255. times are in seconds.
GALVANI_API struct ChannelInfo* GetChannelInfoSquare(int64_t n_pulses, double rising_time, double amp, double pulse_width, double period, double falling_time);

// Get ChannelInfo from sine-rolloff square waveform parameters. amp is represented in control code, and must between 0~255. times are in seconds.
GALVANI_API struct ChannelInfo* GetChannelInfoSine(int64_t n_pulses, double rising_time, double amp, double pulse_width, double period, double falling_time);

// Get ChannelInfo from custom waveform. wave is an array of control code. wave_len is the length of wave. sample_rate is in Sa/s
GALVANI_API struct ChannelInfo* GetChannelInfoCustom(int64_t n_pulses, const char* wave, size_t wave_len, double sample_rate);

// Get GalvaniDevice from NI device name. The device name almost always starts with '/'.
// bias is for Galvani. If bias is in 0-126, it is internal bias. If bias is 128, it is external bias.
GALVANI_API struct GalvaniDevice* GetGalvaniDevice(const char* dev_name, size_t dev_name_len, uint8_t bias);

// Start GalvaniDevice. This should be called first after creating GalvaniDevice, before any other calls with GalvaniDevice.
GALVANI_API void StartGalvaniDevice(struct GalvaniDevice* gd);

// Stop and free the GalvaniDevice. GalvaniDevice should not be used after this call.
GALVANI_API void StopGalvaniDevice(struct GalvaniDevice* gd);

// Assign ChannelInfo to channel. The lib will take over the ownership of ChannelInfo, so it should not be used after this call. Use ci=NULL to stop a channel.
GALVANI_API void GalvaniDeviceSetChannel(struct GalvaniDevice* gd, int channel, struct ChannelInfo* ci);

// Get the status of GalvaniDevice. Status is returned in the bool array. True means the corresponding channel is sending waveform.
// This function returns false on success. The bool array contains meaningless value if the function returns true.
GALVANI_API bool GalvaniDeviceGetStatus(struct GalvaniDevice* gd, bool buffer[128]);

// ======= Low level APIs =======
struct Galvani;

// Init Galvani from National Instrument digital output device
GALVANI_API struct Galvani* galvani_init_ni(const char* ni_device);

// Set Galvani buffer size. This will affect the delay from computer operation to actual waveform output
// buffer: buffer size in seconds
GALVANI_API void galvani_set_buffer_size(struct Galvani* dev, double buffer);

// Get Galvani buffer size in seconds, Returns 0 on fail
GALVANI_API double galvani_get_buffer_size(struct Galvani* dev);

// Get number of samples of total buffer
GALVANI_API uint32_t galvani_get_buffer_size_samples(struct Galvani* dev);

// Get number of samples currently in buffer
GALVANI_API uint32_t galvani_get_buffer_samples(struct Galvani* dev);

// Send binary command to galvani. See comments in main.cpp for command structure.
GALVANI_API void galvani_send_command(struct Galvani* dev, const char* command, int32_t command_count);

// Free any resorces related to struct Galvani
GALVANI_API void galvani_end(struct Galvani* dev);

#ifdef __cplusplus
}
#endif
