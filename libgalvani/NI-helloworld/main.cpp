#define SAMPLES_PER_SEC (8000000. / 19.)
#define DELAY 0.1

#include "galvani-ni.h"

#include <algorithm>
#include <string>
#include <include/NIDAQmx.h>
#include <cassert>
#include <vector>
#include <memory>
#include <shared_mutex>
#include <atomic>
#include <thread>
#include <chrono>

struct Galvani {
	TaskHandle taskHandle = 0;
	uint32_t buffer_size;
};

struct Galvani* galvani_init_ni(const char* ni_device) {
	struct Galvani* ret = new struct Galvani;
	std::string ni_device_str{ ni_device };

	char err_message[2048];
#define DAQmxErrChk(functionCall) { \
	int error; \
	if(DAQmxFailed(error=(functionCall))) { \
		DAQmxGetExtendedErrorInfo(err_message, 2048); \
		FILE *fp = fopen("DAQerr.txt", "a"); \
		fputs("DAQmx Error: ", fp); \
		fputs(err_message, fp); \
		fputs("\n", fp); \
		fclose(fp); \
		return NULL; \
	} \
}

	DAQmxErrChk(DAQmxCreateTask("", &ret->taskHandle));
	DAQmxErrChk(DAQmxCreateDOChan(ret->taskHandle, (ni_device_str + "/Port3").c_str(), "", DAQmx_Val_ChanForAllLines));
	DAQmxErrChk(DAQmxCfgPipelinedSampClkTiming(ret->taskHandle, "", 4000000.0, DAQmx_Val_Rising, DAQmx_Val_ContSamps, 1000));
	DAQmxErrChk(DAQmxSetPauseTrigType(ret->taskHandle, DAQmx_Val_DigLvl));
	DAQmxErrChk(DAQmxSetDigLvlPauseTrigSrc(ret->taskHandle, (ni_device_str + "/PFI2").c_str()));
	DAQmxErrChk(DAQmxSetDigLvlPauseTrigWhen(ret->taskHandle, DAQmx_Val_High));
	DAQmxErrChk(DAQmxSetExportedSampClkOutputTerm(ret->taskHandle, (ni_device_str + "/PFI4").c_str()));
	DAQmxErrChk(DAQmxSetExportedSampClkPulsePolarity(ret->taskHandle, DAQmx_Val_ActiveHigh));
	DAQmxErrChk(DAQmxSetExportedDataActiveEventLvlActiveLvl(ret->taskHandle, DAQmx_Val_ActiveHigh));
	DAQmxErrChk(DAQmxSetExportedDataActiveEventOutputTerm(ret->taskHandle, (ni_device_str + "/PFI3").c_str()));
	DAQmxErrChk(DAQmxSetSampClkUnderflowBehavior(ret->taskHandle, DAQmx_Val_PauseUntilDataAvailable));
	DAQmxErrChk(DAQmxSetWriteRegenMode(ret->taskHandle, DAQmx_Val_DoNotAllowRegen));
#undef DAQmxErrChk
	ret->buffer_size = 0;
	return ret;
}

void galvani_set_buffer_size(struct Galvani* dev, double buffer) {
	char err_message[2048];
#define DAQmxErrChk(functionCall) { \
	int error; \
	if(DAQmxFailed(error=(functionCall))) { \
		DAQmxGetExtendedErrorInfo(err_message, 2048); \
		FILE *fp = fopen("DAQerr.txt", "a"); \
		fputs("DAQmx Error: ", fp); \
		fputs(err_message, fp); \
		fputs("\n", fp); \
		fclose(fp); \
		return; \
	} \
}
	dev->buffer_size = std::max(1000, 8 * int(buffer * SAMPLES_PER_SEC));
	printf("dev->buffer_size = %u\n", dev->buffer_size);
	DAQmxErrChk(DAQmxCfgOutputBuffer(dev->taskHandle, dev->buffer_size));
	DAQmxErrChk(DAQmxTaskControl(dev->taskHandle, DAQmx_Val_Task_Reserve));
	DAQmxErrChk(DAQmxGetWriteSpaceAvail(dev->taskHandle, (uInt32*)&dev->buffer_size));
#undef DAQmxErrChk
}

double galvani_get_buffer_size(struct Galvani* dev) {
	return dev->buffer_size / 8 / SAMPLES_PER_SEC;
}

uint32_t galvani_get_buffer_size_samples(struct Galvani* dev) {
	return dev->buffer_size / 8;
}

uint32_t galvani_get_buffer_samples(struct Galvani* dev) {
#define DAQmxErrChk(functionCall) { \
	int error; \
	if(DAQmxFailed(error=(functionCall))) { \
		char err_message[2048]; \
		DAQmxGetExtendedErrorInfo(err_message, 2048); \
		FILE *fp = fopen("DAQerr.txt", "a"); \
		fputs("DAQmx Error: ", fp); \
		fputs(err_message, fp); \
		fputs("\n", fp); \
		fclose(fp); \
		return 0xffffffff; \
	} \
}
	uInt32 avail;
	DAQmxErrChk(DAQmxGetWriteSpaceAvail(dev->taskHandle, &avail));
	printf("curr = %u, avail = %u\n", dev->buffer_size - avail, avail);
	return dev->buffer_size - avail;
#undef DAQmxErrChk
}

void galvani_send_command(struct Galvani* dev, const char* command, int32_t command_count) {
#define DAQmxErrChk(functionCall) { \
	int error; \
	if(DAQmxFailed(error=(functionCall))) { \
		char err_message[2048]; \
		DAQmxGetExtendedErrorInfo(err_message, 2048); \
		FILE *fp = fopen("DAQerr.txt", "a"); \
		fputs("DAQmx Error: ", fp); \
		fputs(err_message, fp); \
		fputs("\n", fp); \
		fclose(fp); \
		return; \
	} \
}
	DAQmxErrChk(DAQmxWriteDigitalU8(dev->taskHandle, command_count, 1, 100.0, DAQmx_Val_GroupByChannel, (const uInt8*)command, NULL, NULL));
#undef DAQmxErrChk
}

void galvani_end(struct Galvani* dev) {
	if (dev->taskHandle) {
		DAQmxStopTask(dev->taskHandle);
		DAQmxClearTask(dev->taskHandle);
	}
}

struct Waveform {
	virtual double getDuration() = 0;
	virtual uint8_t getSample(double time) = 0;
};

struct SquareWaveform :public Waveform {
	double rising_time;
	double falling_time;
	double amp;
	double pulse_width;
	double period;
	SquareWaveform(double rising_time, double amp, double pulse_width, double period, double falling_time) :rising_time(rising_time), amp(amp), pulse_width(pulse_width), period(period), falling_time(falling_time) {}
	double getDuration() override final { return period; }
	uint8_t getSample(double time) override final {
		assert(time < period);
		if (time < pulse_width) {
			double amplitude = amp * std::min({ 1., time / rising_time, (pulse_width - time) / falling_time });
			return uint8_t(amplitude);
		}
		else
			return 0;
	}
};

struct CustomWaveform :public Waveform {
	std::vector<uint8_t> wave;
	double sample_rate;
	CustomWaveform(const char* wave, size_t wave_len, double sample_rate) :wave(wave, wave + wave_len), sample_rate(sample_rate) {}
	double getDuration() override final { return wave.size() / 1000.; }
	uint8_t getSample(double time) override final {
		assert(time * sample_rate < wave.size());
		return wave[int(time * 1000)];
	}
};

struct ChannelInfo {
	int64_t n_pulses;
	std::unique_ptr<Waveform> wf;
	ChannelInfo(int64_t n_pulses, Waveform* wf) :n_pulses(n_pulses), wf(wf) {}
};

struct ChannelInfo* GetChannelInfoSquare(int64_t n_pulses, double rising_time, double amp, double pulse_width, double period, double falling_time) {
	return new ChannelInfo(n_pulses, new SquareWaveform(rising_time, amp, pulse_width, period, falling_time));
}
struct ChannelInfo* GetChannelInfoCustom(int64_t n_pulses, const char* wave, size_t wave_len, double sample_rate) {
	return new ChannelInfo(n_pulses, new CustomWaveform(wave, wave_len, sample_rate));
}

struct GalvaniDevice {
	std::string dev_name;
	std::vector<std::pair<std::unique_ptr<ChannelInfo>, int64_t> > waveform_array;
	std::shared_mutex lock;
	std::thread worker;
	std::atomic_bool stopped;
	std::atomic_bool error;
	GalvaniDevice(const char* dev_name, size_t dev_name_len) :dev_name(dev_name, dev_name + dev_name_len), waveform_array(128), stopped(true), error(false) {}
};

struct GalvaniDevice* GetGalvaniDevice(const char* dev_name, size_t dev_name_len) {
	return new GalvaniDevice(dev_name, dev_name_len);
}

void galvaniNIWorker(struct GalvaniDevice* gd) {
	std::unique_ptr<struct Galvani> dev(galvani_init_ni(gd->dev_name.c_str()));
	if (!dev) {
		gd->error = true;
		return;
	}
	galvani_set_buffer_size(dev.get(), DELAY * 2);
	std::vector<uint8_t> current_status(128);
	int c_ch = 0;
	for (;;) {
		uint32_t buffer_samples = galvani_get_buffer_samples(dev.get());
		if (buffer_samples == 0xffffffff) {
			galvani_end(dev.get());
			gd->error = true;
			return;
		}
		if (buffer_samples > 8 * DELAY * SAMPLES_PER_SEC) {
			std::this_thread::sleep_for(std::chrono::milliseconds(int64_t(DELAY * 618)));
		}
		else {
			if (gd->stopped) {
				galvani_end(dev.get());
				return;
			}
			std::vector<uint8_t> command_buffer;
			command_buffer.reserve(8 * size_t(DELAY * SAMPLES_PER_SEC));
			{
				std::unique_lock<std::shared_mutex> guard(gd->lock);
				for (int i = 0; i<int(DELAY * SAMPLES_PER_SEC); ++i) {
					bool is_running = false;
					for (auto&& x : gd->waveform_array) {
						if (x.first) {
							is_running = true;
							break;
						}
					}
					if (!is_running) {
						for (auto&& x : current_status) {
							if (x) {
								is_running = true;
								break;
							}
						}
					}
					if (is_running) {
						std::vector<uint8_t> target_status(128);
						for (int i = 0; i < 128; ++i) {
							if (gd->waveform_array[i].first) {
								auto wf = gd->waveform_array[i].first.get();
								auto offset = gd->waveform_array[i].second;
								double offset_time = offset / SAMPLES_PER_SEC;
								offset_time -= wf->wf->getDuration() * (floor(offset_time / wf->wf->getDuration()));
								target_status[i] = wf->wf->getSample(offset_time);
								if (wf->n_pulses && offset + 1 >= SAMPLES_PER_SEC * wf->wf->getDuration() * wf->n_pulses) {
									gd->waveform_array[i].first.reset();
								}
								else {
									++gd->waveform_array[i].second;
								}
							}
						}
						int c_ch_offset = 0;
						for (; c_ch_offset < 32; ++c_ch_offset) {
							int ch = (c_ch + c_ch_offset) % 32;
							if (current_status[ch] != target_status[ch] || current_status[ch + 32] != target_status[ch + 32] || current_status[ch + 64] != target_status[ch + 64] || current_status[ch + 96] != target_status[ch + 96]) {
								break;
							}
						}
						c_ch = (c_ch + c_ch_offset) % 32;
						command_buffer.emplace_back(0xaa);
						command_buffer.emplace_back(0x20 | c_ch);
						command_buffer.emplace_back(0x00);
						command_buffer.emplace_back(target_status[c_ch]);
						command_buffer.emplace_back(target_status[c_ch + 32]);
						command_buffer.emplace_back(target_status[c_ch + 64]);
						command_buffer.emplace_back(target_status[c_ch + 96]);
						command_buffer.emplace_back(0xab);
						current_status[c_ch] = target_status[c_ch];
						current_status[c_ch + 32] = target_status[c_ch + 32];
						current_status[c_ch + 64] = target_status[c_ch + 64];
						current_status[c_ch + 96] = target_status[c_ch + 96];
						c_ch = (c_ch + 1) % 32;
					}
					else {
						break;
					}
				}
			}
			if (!command_buffer.empty()) {
				printf("sending commands: len=%d\n", command_buffer.size());
				galvani_send_command(dev.get(), reinterpret_cast<char*>(command_buffer.data()), command_buffer.size());
			}
			else {
				std::this_thread::sleep_for(std::chrono::milliseconds(int64_t(DELAY * 618)));
			}
		}
	}
}

void StartGalvaniDevice(struct GalvaniDevice* gd) {
	gd->stopped = false;
	gd->worker = std::thread(galvaniNIWorker, gd);
}

void StopGalvaniDevice(struct GalvaniDevice* gd) {
	gd->stopped = true;
	gd->worker.join();
	delete gd;
}

void GalvaniDeviceSetChannel(struct GalvaniDevice* gd, int channel, struct ChannelInfo* ci) {
	std::unique_lock<std::shared_mutex> guard(gd->lock);
	if (ci)
		gd->waveform_array[channel] = std::pair<std::unique_ptr<ChannelInfo>, int64_t>(ci, 0);
	else
		gd->waveform_array[channel] = std::pair<std::unique_ptr<ChannelInfo>, int64_t>();
}

bool GalvaniDeviceGetStatus(struct GalvaniDevice* gd, bool buffer[128]) {
	for (int i = 0; i < 128; ++i) {
		buffer[i] = bool(gd->waveform_array[i].first);
	}
	return gd->error;
}
