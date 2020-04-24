#! /usr/bin/env python

import time
from _galvanini.lib import galvani_init_ni, galvani_set_buffer_size, galvani_get_buffer_size, galvani_get_buffer_size_samples, galvani_get_buffer_samples, galvani_end
import _galvanini


def galvani_send_command(dev, c, n):
    a = time.time()
    _galvanini.lib.galvani_send_command(dev, c, n)
    a = time.time() - a
    print(f'send command took {a}s')