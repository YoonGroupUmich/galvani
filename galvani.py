#! /usr/bin/env python

from _galvanini.lib import (GetChannelInfoSquare, GetChannelInfoCustom, GetGalvaniDevice, StartGalvaniDevice,
                            StopGalvaniDevice, GalvaniDeviceSetChannel, GalvaniDeviceGetStatus)
from _galvanini import ffi


class SquareWaveform:

    def __init__(self, rising_time=0., amp=0., pulse_width=0., period=0., falling_time=0.):
        self.rising_time = rising_time
        self.falling_time = falling_time
        self.amp = amp
        self.period = period
        self.pulse_width = pulse_width


class CustomWaveform:
    def __init__(self, wave=None):
        if wave is None:
            self.wave = []
        else:
            self.wave = wave
