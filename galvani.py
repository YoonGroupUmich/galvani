#! /usr/bin/env python

import threading
import struct
import time
import numpy as np
from typing import List
import logging

import galvanini


def generate_cmd(mode, bias_sel, bias_amp, addr, amp0, amp1, amp2, amp3):
    return struct.pack('BBBBBBBB', 0xaa, (mode << 5) | addr,
                       (bias_sel << 7) | bias_amp, amp0, amp1, amp2, amp3, 0xab)


class Waveform:
    def get_duration(self):
        return 0

    def get_sample(self, time):
        return 0


class SquareWaveform(Waveform):

    def __init__(self, mode=0, amp=0., pw=0., period=0.):
        """
        mode: controls the rising/falling edge width
        mode       rising edge width (ms)
          0                 0
          1                 0.1
          2                 0.5
          3                 1
          4                 2

        amp: controls the wave amplitude, unit: uA, range: [0, 155.9].
        amp=0 can be used to stop the channel

        period: controls the wave period, unit: second, range: [0, 17.98].
        pw: controls the wave pulse width, unit: second, range: [0, period]
        """
        self.mode = mode
        self.amp = amp
        self.period = period
        self.pulse_width = pw

    def get_duration(self):
        return self.period

    def get_sample(self, time):
        return self.amp if time < self.pulse_width else 0


class CustomWaveform(Waveform):
    def __init__(self, wave=None):
        if wave is None:
            self.wave = []
        else:
            self.wave = wave

    def get_duration(self):
        return len(self.wave) / 1000

    def get_sample(self, time):
        try:
            return self.wave[int(time * 1000)]
        except IndexError:
            return 0


class ChannelInfo:
    def __init__(self, waveform: Waveform, n_pulses=1):
        """
        waveform: the waveform object.
        n_pulses: positive integer. Number of pulses
        """
        self.wf = waveform
        self.n_pulses = n_pulses


class GalvaniDevice:
    def __init__(self, dev_name: str, status_callback):
        self.dev_name = dev_name
        self.waveform_array = [None for _ in range(128)]
        self.lock = threading.RLock()
        self.worker = GalvaniNIWorker(self, status_callback)
        self.stopped = True

    def start(self):
        with self.lock:
            self.stopped = False
        self.worker.start()

    def stop(self):
        with self.lock:
            self.stopped = True
        self.worker.join()

    def set_channel(self, chs: List[int], wf:ChannelInfo):
        with self.lock:
            try:
                for ch in chs:
                    if wf is None:
                        self.waveform_array[ch] = None
                    else:
                        self.waveform_array[ch] = (wf, 0)
            except TypeError:
                if wf is None:
                    self.waveform_array[chs] = None
                else:
                    self.waveform_array[chs] = (wf, 0)




class GalvaniNIWorker(threading.Thread):
    COMMAND_RATE = 500000 / 19
    DELAY = 0.1

    def __init__(self, dev: GalvaniDevice, status_callback):
        threading.Thread.__init__(self, daemon=True)
        self.gd = dev
        self.dev = galvanini.galvani_init_ni(dev.dev_name.encode())
        galvanini.galvani_set_buffer_size(self.dev, self.DELAY * 2)
        self.status_callback = status_callback
        #galvanini.galvani_send_command(self.dev, b'\x00\x00\x00\x00', 4)

    def run(self):
        current_status = np.zeros(128, dtype='uint8')
        c_ch = 0
        while True:
            buffer_samples = galvanini.galvani_get_buffer_samples(self.dev)
            if buffer_samples > 3 * self.DELAY * self.COMMAND_RATE:
                print('Buffer is full', buffer_samples)
                time.sleep(self.DELAY * .1)
            else:
                if buffer_samples == 0:
                    print('Buffer is empty')
                with self.gd.lock:
                    waveform_array = self.gd.waveform_array.copy()
                    if self.gd.stopped:
                        galvanini.galvani_end(self.dev)
                        return
                    time_took = time.time()
                    command_buffer = b''
                    for samples in range(int(self.DELAY * self.COMMAND_RATE)):
                        is_running = False
                        for x in self.gd.waveform_array:
                            if x is not None:
                                is_running = True
                                break
                        if is_running or np.any(current_status):
                            target_status = np.zeros(128, dtype='uint8')
                            for i in range(128):
                                if self.gd.waveform_array[i] is not None:
                                    wf, offset = self.gd.waveform_array[i]
                                    target_status[i] = wf.wf.get_sample((offset / self.COMMAND_RATE) % wf.wf.get_duration())
                                    if wf.n_pulses and offset + 1 >= self.COMMAND_RATE * wf.wf.get_duration() * wf.n_pulses:
                                        self.gd.waveform_array[i] = None
                                    else:
                                        self.gd.waveform_array[i] = (wf, offset + 1)
                            status_diff = current_status != target_status
                            status_diff = np.roll(status_diff.reshape((4,32)).any(0), -c_ch)
                            diff_idx = np.nonzero(status_diff)[0]
                            if diff_idx.size:
                                c_ch = (c_ch + diff_idx[0]) % 32
                            command_buffer += (
                                generate_cmd(1, 0, 0, c_ch, target_status[c_ch], target_status[c_ch + 32],
                                             target_status[c_ch + 64], target_status[c_ch + 96]))
                            current_status[c_ch::32] = target_status[c_ch::32]
                            c_ch = (c_ch + 1) % 32
                        else:
                            break
                if command_buffer:
                    time_took = time.time() - time_took
                    galvanini.galvani_send_command(self.dev, command_buffer, len(command_buffer))
                    if time_took > self.DELAY:
                        print('Command generation speed slower than realtime!!! Waveform distorted!!!')
                        print(f'Generating command of {self.DELAY}s took {time_took}s')
                else:
                    time.sleep(self.DELAY * .1)
                self.status_callback(waveform_array)
