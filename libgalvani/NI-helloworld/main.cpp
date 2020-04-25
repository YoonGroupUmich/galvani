//#define LOAD_CSV "wave.csv"
#define LOAD_BIN "cmds.bin"
#define DEVICE "/Dev1"
#define SAMPLES_PER_SEC (500000. / 19.)

#include "galvani-ni.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <algorithm>
#include <string>
#include <include/NIDAQmx.h>

#ifdef LOAD_CSV
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#endif

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
		fputs("DAQmx Error: ", stderr); \
		fputs(err_message, stderr); \
		fputs("\n", stderr); \
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
		fputs("DAQmx Error: ", stderr); \
		fputs(err_message, stderr); \
		fputs("\n", stderr); \
		return; \
	} \
}
	dev->buffer_size = std::max(1000, int(buffer * SAMPLES_PER_SEC));
	printf("dev->buffer_size = %u\n", dev->buffer_size);
	DAQmxErrChk(DAQmxCfgOutputBuffer(dev->taskHandle, int(dev->buffer_size * SAMPLES_PER_SEC)));
	DAQmxErrChk(DAQmxTaskControl(dev->taskHandle, DAQmx_Val_Task_Reserve));
	DAQmxErrChk(DAQmxGetWriteSpaceAvail(dev->taskHandle, (uInt32*)&dev->buffer_size));
#undef DAQmxErrChk
}

double galvani_get_buffer_size(struct Galvani* dev) {
	return dev->buffer_size / SAMPLES_PER_SEC;
}

uint32_t galvani_get_buffer_size_samples(struct Galvani* dev) {
	return dev->buffer_size;
}

uint32_t galvani_get_buffer_samples(struct Galvani* dev) {
#define DAQmxErrChk(functionCall) { \
	int error; \
	if(DAQmxFailed(error=(functionCall))) { \
		char err_message[2048]; \
		DAQmxGetExtendedErrorInfo(err_message, 2048); \
		fputs("DAQmx Error: ", stderr); \
		fputs(err_message, stderr); \
		fputs("\n", stderr); \
		return 0; \
	} \
}
	uInt32 avail;
	DAQmxErrChk(DAQmxGetWriteSpaceAvail(dev->taskHandle, &avail));
	printf("avail = %u\n", avail);
	return dev->buffer_size - avail;
#undef DAQmxErrChk
}

void galvani_send_command(struct Galvani* dev, const char* command, int32_t command_count) {
#define DAQmxErrChk(functionCall) { \
	int error; \
	if(DAQmxFailed(error=(functionCall))) { \
		char err_message[2048]; \
		DAQmxGetExtendedErrorInfo(err_message, 2048); \
		fputs("DAQmx Error: ", stderr); \
		fputs(err_message, stderr); \
		fputs("\n", stderr); \
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