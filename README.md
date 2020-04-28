## Galvani
**Galvani is a 128 channel uLED stimulator board with precise and independent channel waveform control**.

## Windows Binaries
Windows binaries are available for download at https://github.com/YoonGroupUmich/galvani/releases . NI-DAQmx is required to run the program. The FPGA needs to be programmed before connected via the GUI

## Build from source
To build and run from source,

* Install Python (On Windows, use the **32-bit** version, as NI only provides 32-bit library)
* Install python dependencies: `python -m pip install cffi matplotlib numpy wxpython`
* Clone the project: `git clone https://github.com/YoonGroupUmich/galvani.git`
* Open `hardware/GALVANI_STIM.qpf` in Quartus. Compile the project and program the FPGA.
* Open `libgalvani/NI-helloworld.sln` in Visual Studio. Select "Release x86" target and build the project.
    * Alternatively, you can also build a shared object using any compiler toolchain, from `libgalvani/NI-helloworld/galvani-ni.h` and `libgalvani/NI-helloworld/main.cpp`
* Run `make_dist.bat`
    * If you are not using Visual Studio in the previous step, or you are not on Windows, you need to manually modify the compiled library path in `galvani_cffi_build.py` and run it.
* Run `python galgui.py`
    * Or the `galgui` executable in `dist/galgui`