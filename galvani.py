#! /usr/bin/env python

from _galvanini.lib import (GetChannelInfoSquare, GetChannelInfoSine, GetChannelInfoCustom, GetGalvaniDevice,
                            StartGalvaniDevice, StopGalvaniDevice, GalvaniDeviceSetChannel, GalvaniDeviceGetStatus)
from _galvanini import ffi

lsb = [0.553,0.559,0.567,0.575,0.583,0.593,0.6,0.608,0.615,0.624,0.632,0.639,0.648,0.656,0.663,0.673,0.68,0.69,0.698,0.705,0.713,0.722,0.731,0.739,0.749,0.758,0.768,0.778,0.785,0.793,0.8,0.805,0.813,0.82,0.827,0.834,0.842,0.849,0.857,0.864,0.872,0.879,0.887,0.894,0.902,0.909,0.916,0.924,0.931,0.939,0.946,0.954,0.962,0.969,0.977,0.984,0.993,1,1.007,1.016,1.023,1.031,1.039,1.037,1.044,1.052,1.06,1.068,1.076,1.084,1.092,1.099,1.107,1.115,1.123,1.131,1.138,1.147,1.155,1.162,1.17,1.178,1.186,1.194,1.202,1.21,1.219,1.226,1.234,1.242,1.251,1.259,1.267,1.275,1.284,1.289,1.297,1.305,1.314,1.322,1.331,1.339,1.347,1.355,1.363,1.372,1.38,1.388,1.397,1.405,1.414,1.422,1.43,1.439,1.447,1.456,1.464,1.473,1.481,1.489,1.498,1.506,1.515,1.523,1.532,1.541,1.55]

class SquareWaveform:
    def __init__(self, rising_time=0., amp=0., pulse_width=0., period=0., falling_time=0.):
        self.rising_time = rising_time
        self.falling_time = falling_time
        self.amp = amp
        self.period = period
        self.pulse_width = pulse_width


class CustomWaveform:
    def __init__(self, wave=None, sample_rate=1000):
        if wave is None:
            self.wave = []
        else:
            self.wave = wave
        self.sample_rate = sample_rate
