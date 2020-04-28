from cffi import FFI
ffibuilder = FFI()

# cdef() expects a single string declaring the C types, functions and
# globals needed to use the shared object. It must be in valid C syntax.
ffibuilder.cdef('''
struct ChannelInfo* GetChannelInfoSquare(int64_t n_pulses, double rising_time, double amp, double pulse_width, double period, double falling_time);
struct ChannelInfo* GetChannelInfoCustom(int64_t n_pulses, const char* wave, size_t wave_len, double sample_rate);
struct GalvaniDevice* GetGalvaniDevice(const char* dev_name, size_t dev_name_len);
void StartGalvaniDevice(struct GalvaniDevice* gd);
void StopGalvaniDevice(struct GalvaniDevice* gd);
void GalvaniDeviceSetChannel(struct GalvaniDevice* gd, int channel, struct ChannelInfo* ci);
bool GalvaniDeviceGetStatus(struct GalvaniDevice* gd, bool buffer[128]);
''')

# set_source() gives the name of the python extension module to
# produce, and some C source code as a string.  This C code needs
# to make the declarated functions, types and globals available,
# so it is often just the "#include".
ffibuilder.set_source("_galvanini", '#include "libgalvani/NI-helloworld/galvani-ni.h"',
     libraries=['libgalvani/Release/libgalvani-ni'])   # library name, for the linker

if __name__ == "__main__":
    ffibuilder.compile(verbose=True)
