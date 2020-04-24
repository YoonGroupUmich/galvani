from cffi import FFI
ffibuilder = FFI()

# cdef() expects a single string declaring the C types, functions and
# globals needed to use the shared object. It must be in valid C syntax.
ffibuilder.cdef('''
struct Galvani* galvani_init_ni(char* ni_device);
void galvani_set_buffer_size(struct Galvani* dev, double buffer);
double galvani_get_buffer_size(struct Galvani* dev);
uint32_t galvani_get_buffer_size_samples(struct Galvani* dev);
uint32_t galvani_get_buffer_samples(struct Galvani* dev);
void galvani_send_command(struct Galvani* dev, char* command, int32_t command_count);
void galvani_end(struct Galvani* dev);
''')

# set_source() gives the name of the python extension module to
# produce, and some C source code as a string.  This C code needs
# to make the declarated functions, types and globals available,
# so it is often just the "#include".
ffibuilder.set_source("_galvanini", '#include "galvani-ni.h"',
     libraries=['libgalvani-ni'])   # library name, for the linker

if __name__ == "__main__":
    ffibuilder.compile(verbose=True)