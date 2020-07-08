// Control National Instruments PCIe-6536 interface:
// ASIC <-> FPGA <-> (this program) <-> file <-> neuroscope (256+ channels)

#include <stdio.h> /* printf(),  more */
#include <stdlib.h> /* snprintf */
#include <stdbool.h>
#include "include/NIDAQmx.h" /* LabView hw calls */
#include <Windows.h>
#include <windows.h>
#include <conio.h> /* kbhit() */
//#include "filt.h"
#define DEVICE "/PXI1Slot6"

#define SAMPLE_CLK_FREQ (1*400*1000) 
#define PCI_6536_BUFFER_SIZE (128*10000) // PCI-6536 buffer size
#define SAMPS_PER_LINE_TO_READ (32000) // A sample contains binary values of all lines from fpga (currently 22) @ rising edge of sample clock  

// Note: a single bit from a line from the FPGA occupies an entire byte in the incoming HW buffer
#define LINES_FROM_FGPA (22) 

#define ADC_RES_BITS (10)
#define ADC_RES_BYTES (2) 

// number of SPI busses, each outputting two 10-bit samples
#define NUM_PAIRS (8)
#define SAMP_SIZE_SHORT (256)
#define INIT_TRUE (1)
#define INIT_FALSE (0)

#define INPUT_BUFFER_SIZE_BYTES (SAMPS_PER_LINE_TO_READ * LINES_FROM_FGPA) // each sample contains LINES_FROM_FPGA bytes

//#define OUTPUT_BUFFER_SIZE_BYTES (INPUT_BUFFER_SIZE_BYTES*(ADC_RES_BITS/ADC_SAMPLE_SIZE_BYTES)) 
#define OUTPUT_BUFFER_SIZE_BYTES (SAMPS_PER_LINE_TO_READ*(LINES_FROM_FGPA-2)/5) // output buffer consumes 2 bytes per samples, whereas input buffer consumes 10 bytes per adc sample, thus 5x reduction in size
#define OUTPUT_BUFFER_SIZE_SHORTS (OUTPUT_BUFFER_SIZE_BYTES/2)
#define SYNC_BIT (1)

#define NO_AUTO_START (0)
#define AUTO_START (1)
#define READ_TIMEOUT (-1)

#define DAQmxErrChk(func) if(DAQmxFailed(res=(func))) goto Error; else

int condense(uInt8 arr[], uInt8 arr2[]);
void condense_buf(uInt8 in[], uInt8 out[], unsigned int tot_samps_per_line);
int unweave256(char buf[], unsigned int len_bytes);
void read(TaskHandle task, uInt8 in_buf[], int32 n_samples);
int check_for_sync_bit(TaskHandle task, uInt8 in_buf[], uInt8 out_buf[], FILE* fp);
void printn();

// https://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format
#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0') 

int main() {

    TaskHandle read_task=0;

    int32 res=0;
    char errBuff[2048]={'\0'};

    uInt8 in_buf[INPUT_BUFFER_SIZE_BYTES] = {'\0'};
    uInt8 out_buf[OUTPUT_BUFFER_SIZE_BYTES] = {'\0'};
    unsigned int out_buf_len = 0;
    int32 samples_per_chan_read;
    int32 n_bytes_per_sample;
    int sync_bit_found = 0;

    FILE *write_ptr;
    FILE *debug_ptr;
    FILE* trig_out_ptr;

    char filename[100];
    SYSTEMTIME st = {0};

    GetLocalTime(&st);

    _snprintf(filename, 100, "mint_%d-%02d-%02d_%02d-%02d-%02d.dat", st.wYear, st.wMonth, st.wDay, \
            st.wHour, st.wMinute, st.wSecond);
    //printf("%s\n", filename);
    //write_ptr = fopen(filename,"wb");
    write_ptr = fopen("test.dat","wb");
    debug_ptr = fopen("debug.dat","wb");
    trig_out_ptr = fopen("trigger_out.dat", "wb");

    DAQmxErrChk(DAQmxCreateTask("read_task", &read_task));


    DAQmxErrChk(DAQmxCreateDIChan(read_task, DEVICE "/port2/line6, " 
                                        DEVICE "/port3/line7, " DEVICE "/port3/line5, " DEVICE "/port3/line3, " DEVICE "/port3/line1, " DEVICE "/port2/line7, " DEVICE "/port2/line5, " DEVICE "/port2/line3, " DEVICE "/port2/line1, " DEVICE "/port1/line7, " DEVICE "/port1/line5, "  // A9 .. A0
                                        DEVICE "/port1/line3, " DEVICE "/port1/line1, " DEVICE "/port1/line6, " DEVICE "/port1/line4, " DEVICE "/port1/line2, " DEVICE "/port1/line0, " DEVICE "/port3/line6, " DEVICE "/port3/line4, " DEVICE "/port3/line2, " DEVICE "/port3/line0, "  // B9 .. B0
                                        DEVICE "/port2/line2",  // Trigger out
                                        "", DAQmx_Val_ChanForAllLines));
    printf("create digital channel: %d\n", res);   

    DAQmxErrChk(DAQmxCfgSampClkTiming(read_task, DEVICE "/PFI5", SAMPLE_CLK_FREQ, DAQmx_Val_Rising, DAQmx_Val_ContSamps, INPUT_BUFFER_SIZE_BYTES));
    printf("configure sample clock timing: %d\n", res);

    unsigned int buf_sz;

    DAQmxGetBufInputBufSize(read_task, &buf_sz);
    printf("buf size = %u\n", buf_sz);

    DAQmxErrChk(DAQmxTaskControl(read_task, DAQmx_Val_Task_Verify));
    printf("verify task: %d\n", res);

    DAQmxErrChk(DAQmxStartTask(read_task));
    printf("start task: %d\n", res);
	
    //printf("waiting for sync bit...\n");
    //wait_for_sync_bit(read_task, in_buf, out_buf, write_ptr);
    //hpf_buf(out_buf, (unsigned int) SAMP_SIZE_SHORT, INIT_TRUE);
    printf("press any key to stop...\n");
    printf("checking for sync bit...\n");

    sync_bit_found = 0;
    while (!kbhit()) { // wait for keyboard input to break read loop
        if (!sync_bit_found) {
            sync_bit_found = check_for_sync_bit(read_task, in_buf, out_buf, write_ptr, trig_out_ptr);
            if (sync_bit_found) {
                printf("synchronized!\n");
                printf("reading neural data...\n");
            }
        } else {
            read(read_task, in_buf, SAMPS_PER_LINE_TO_READ);
            condense_buf(in_buf, out_buf, SAMPS_PER_LINE_TO_READ, trig_out_ptr);
            unweave256(out_buf, OUTPUT_BUFFER_SIZE_BYTES);
            //filt_bit_err_buf(out_buf, 256, false);
            //hpf_buf(out_buf, OUTPUT_BUFFER_SIZE_SHORTS, INIT_FALSE);
            fwrite(out_buf, OUTPUT_BUFFER_SIZE_BYTES, 1, write_ptr); 
        }
    }


    fclose(debug_ptr);
    fclose(write_ptr);
    fclose(trig_out_ptr);
    DAQmxStopTask(read_task);
    DAQmxClearTask(read_task);
    
	printf("clear task: %d", res);
    return 0;

Error:
       if( DAQmxFailed(res) )
              DAQmxGetExtendedErrorInfo(errBuff,2048);
       if( read_task!=0 ) 
              DAQmxStopTask(read_task);
              DAQmxClearTask(read_task);
       if( DAQmxFailed(res) )
              printf("DAQmx Error: %s\n",errBuff);
              return 0;
}

void read(TaskHandle task, uInt8 in_buf[], int32 n_samples) {
    int32 res;
    DAQmxReadDigitalLines(task, n_samples, READ_TIMEOUT, DAQmx_Val_GroupByChannel, in_buf, n_samples*LINES_FROM_FGPA, NULL, NULL, NULL);
}

// This function assumes condensation from 10 bytes (each with 1 useful bit) down to 2 bytes (with 10 bits of info)
int condense(uInt8 arr[], uInt8 arr2[]) {
    arr2[0] = (arr[0] << 1) | arr[1];
    arr2[1] = ((arr[2] << 7) | (arr[3] << 6) | (arr[4] << 5) | (arr[5] << 4) | (arr[6] << 3) | (arr[7] << 2) | (arr[8] << 1) | arr[9]);
    return 0;
}

// This function uses the condense() function on buffered data
void condense_buf(uInt8 in[], uInt8 out[], unsigned int tot_samps_per_line, FILE* trig_out_ptr) {
    unsigned int i = 0;
    unsigned int j = 0;
    int sync_flag = 0;
    static int ch_pair = 0;
    unsigned int samples = 0;
    const char zero = 0;

    while (samples < tot_samps_per_line) {
        sync_flag = in[i];

        if ((0 == ch_pair) && (0 == sync_flag)) {
            printf("synchronization failure...\n");
        } else {
            //printn();
        }

        i += SYNC_BIT; 
        condense(&in[i], &out[j]);
        i += ADC_RES_BITS;  // reminder: input buffer stores each adc result in ADC_RES_BITS bytes
        j += ADC_RES_BYTES; 
        condense(&in[i], &out[j]);
        i += ADC_RES_BITS;  
        j += ADC_RES_BYTES;

        // Write trigger out data
        fwrite(&in[i], 1, 1, trig_out_ptr);
        fwrite(&zero, 1, 1, trig_out_ptr);  // Little endian
        i += 1;

        ch_pair++;
        if (128 <= ch_pair) ch_pair = 0;

        samples += 1;
    }
    return;
}

// unweave256():
// go from:
// ch0s0 ch16s0 ch32s0 ch48s0 ... ch224s0 ch240s0 ch1s0 ch17s0 ... ch15s0 ch31s0 ch47s0 ... ch239s0 ch255s0 ch0s1 ch16s1 ...
// to:
// ch0s0 ch1s0 ch2s0 ch3s0 ... ch254s0 ch255s0 ch0s1 ch1s1 ch2s1 ch3s1 ... ch255s1 ch0s2 ...
// where chNsM represents sample M from channel N stored within 2 bytes each.
int unweave256(char buf[], unsigned int len_bytes) {

    char tempA[8][32];
    char tempB[8][32];
    char t;

    int i, j, k;
    int x, y;

    // this for loop just flips endianness 
    //for (i = 0; i < len_bytes; i+=2) {
    //    t = buf[i];
    //    buf[i] = buf[i+1];
    //    buf[i+1] = t;
    //}

    for (k = 0; k < len_bytes; k+=512) {
        for (i = k, x = 0, y = 0; i < (k+512); i+=64) {
            for (j = i; j < (i+64); j+=4) {
                // go from big to little endian (neuroscope expects little endian)
                tempA[x][y+1] = buf[j];
                tempA[x][y] = buf[j+1];
                tempB[x][y+1] = buf[j+2];
                tempB[x][y] = buf[j+3];
                if (7 == x) {
                    x = 0;
                    y+=2;
                } else {
                    x++;
                }
            }
        }
        for (i = k, x = 0; i < (k+512); i+=64) {
            memcpy(&buf[i], &tempA[x], 32);
            memcpy(&buf[i+32], &tempB[x], 32);
            x++;
        }
    }


    return 0;
}

int check_for_sync_bit(TaskHandle task, uInt8 in_buf[], uInt8 out_buf[], FILE* fp, FILE* trig_out_ptr) {
    //DAQmxReadDigitalLines(task, 1, READ_TIMEOUT, DAQmx_Val_GroupByChannel, in_buf, LINES_FROM_FGPA, &samples_per_chan_read, &n_bytes_per_sample, NULL);
    int sync_flag;
    read(task, in_buf, 1);
    sync_flag = in_buf[0];
    if (sync_flag) {
        read(task, &(in_buf[22]), 127);
        condense_buf(in_buf, out_buf, 128, trig_out_ptr);
        unweave256(out_buf, 512);
        //filt_bit_err_buf(out_buf, 256, true);
        fwrite(out_buf, 512, 1, fp); 
        return 1;
    }
    return 0;
}

void printn() {
    static int n = 0;
    const int threshold = 512;
    if (threshold == n) {
        printf("n = %d\n", threshold);
        n = 0;
    }
    n++;
}
