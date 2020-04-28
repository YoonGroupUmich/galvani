#! /usr/bin/env python

import configparser
import json
import logging
import matplotlib.pyplot as plt
import os
import sys
import time
from typing import List
import wx
import wx.lib.scrolledpanel
import numpy as np

import galvani

__version__ = '0.0.1'

logging.basicConfig(level=os.environ.get("LOGLEVEL", "DEBUG"))
galgui_config = configparser.ConfigParser()
galgui_config.read('config.ini')


class LabeledCtrl(wx.BoxSizer):
    def __init__(self, control, parent=None, ident=-1, label=''):
        wx.BoxSizer.__init__(self, wx.VERTICAL)
        self.Add(wx.StaticText(parent, ident, label), 1, wx.EXPAND)
        self.Add(control, 1, wx.EXPAND)


class ChannelCtrl:
    _error_color = wx.Colour(255, 172, 172)
    _warning_color = wx.Colour(206, 206, 0)
    _normal_color = wx.Colour(91, 214, 255)
    _disabled_color = wx.NullColour

    def __init__(self, ch: int, channel_label: wx.StaticText,
                 waveform_choice: wx.Choice,
                 continuous_toggle: wx.ToggleButton, trigger_button: wx.Button,
                 stop_button: wx.Button,
                 status_text: wx.TextCtrl, del_button: wx.Button, sizers: List[wx.Sizer], mf):
        self.ch = ch
        self.mf = mf
        self.channel_label = channel_label
        self.channel_name = channel_label.GetLabel()
        self.waveform_choice = waveform_choice
        self.waveform_choice.Bind(wx.EVT_CHOICE, self.on_waveform_choice)
        self.continuous_toggle = continuous_toggle
        self.continuous_toggle.Bind(wx.EVT_TOGGLEBUTTON, self.on_toggle)
        self.trigger_button = trigger_button
        trigger_button.Bind(wx.EVT_BUTTON, self.on_trigger)
        self.stop_button = stop_button
        self.stop_button.Bind(wx.EVT_BUTTON, self.on_stop)
        self.status_text = status_text

        self.waveform = 'Waveform 1'
        self.continuous = False
        self.modified = False
        self.del_button = del_button
        self.del_button.Bind(wx.EVT_BUTTON, self.on_del)
        self.sizers = sizers

    def on_connect(self):
        self.stop_button.Enable()
        self.trigger_button.Enable()

    def on_disconnect(self):
        self.stop_button.Disable()
        self.trigger_button.Disable()
        self.status_text.SetBackgroundColour(wx.NullColour)
        self.status_text.SetValue('Board not connected')

    def update_status(self, status):
        if status:
            self.status_text.SetBackgroundColour(self._normal_color)
            self.status_text.SetValue('Normal')
        else:
            self.status_text.SetBackgroundColour(wx.NullColour)
            self.status_text.SetValue('Stopped')

    def on_toggle(self, event: wx.Event):
        obj = event.GetEventObject()
        val = obj.GetValue()
        obj.SetLabel('Continuous' if val else 'One-shot')
        self.continuous = val
        self.set_modified()
        if galgui_config['Waveform']['realtime_update'] == 'yes':
            self.mf.on_update(None)

    def update_param(self):
        self.waveform = self.waveform_choice.GetStringSelection()
        self.continuous = self.continuous_toggle.GetValue()
        self.modified = False
        self.channel_label.SetLabel(self.channel_name)

    def to_dict(self):
        return {'ch':self.ch, 'channel_name': self.channel_name, 'waveform': self.waveform,
                'continuous': self.continuous}

    def from_dict(self, d: dict):
        assert self.channel_name == d['channel_name'], 'Channel name mismatch'
        self.waveform_choice.SetSelection(
            self.waveform_choice.FindString(d['waveform'], caseSensitive=True))
        self.continuous_toggle.SetLabel('Continuous' if d['continuous'] else 'One-shot')
        self.continuous_toggle.SetValue(d['continuous'])
        self.set_modified()

    def set_modified(self):
        self.modified = True
        self.channel_label.SetLabel('*' + self.channel_name)

    def on_waveform_choice(self, event: wx.Event):
        self.set_modified()
        if galgui_config['Waveform']['realtime_update'] == 'yes':
            self.mf.on_update(None)

    def on_trigger(self, event: wx.Event):
        wf = self.waveform_choice.GetSelection()
        if self.continuous:
            data = self.mf.wfm.waveform_panels[wf].channel_info(n_pulses=0)
        else:
            data = self.mf.wfm.waveform_panels[wf].channel_info()
        galvani.GalvaniDeviceSetChannel(self.mf.device, self.ch, data)

    def on_stop(self, event: wx.Event):
        galvani.GalvaniDeviceSetChannel(self.mf.device, self.ch, galvani.ffi.NULL)

    def on_del(self, event: wx.Event):
        self.mf.Freeze()
        for x in self.sizers:
            self.mf.channel_box.Detach(x)
            while not x.IsEmpty():
                x.Detach(0)
        self.channel_label.Destroy()
        self.waveform_choice.Destroy()
        self.continuous_toggle.Destroy()
        self.trigger_button.Destroy()
        self.stop_button.Destroy()
        self.status_text.Destroy()
        self.del_button.Destroy()
        self.mf.p.Layout()
        self.mf.Thaw()
        self.mf.channels_ui.remove(self)


class SquareWavePanel(wx.FlexGridSizer):
    def __init__(self, parent, modify_callback, init_dict=None):
        wx.FlexGridSizer.__init__(self, 2, 5, 5, 5)
        for i in range(5):
            self.AddGrowableCol(i, 1)
        self.Add(wx.StaticText(parent, -1, 'Amplitude (\u03bcA)'), 0, wx.EXPAND)
        self.Add(wx.StaticText(parent, -1, 'Period (ms)'), 0, wx.EXPAND)
        self.Add(wx.StaticText(parent, -1, 'Pulse Width (ms)'), 0, wx.EXPAND)
        self.Add(wx.StaticText(parent, -1, 'Rising Time (ms)'), 0, wx.EXPAND)
        self.Add(wx.StaticText(parent, -1, 'Falling Time (ms)'), 0, wx.EXPAND)

        try:
            self.amp = init_dict['amp']
        except (TypeError, KeyError, ValueError):
            self.amp = 0  # uA
        try:
            self.pulse_width = init_dict['pulse_width']
        except (TypeError, KeyError, ValueError):
            self.pulse_width = 0  # ms
        try:
            self.period = init_dict['period']
        except (TypeError, KeyError, ValueError):
            self.period = 0  # ms
        try:
            self.rise_time = init_dict['rise_time']
        except (TypeError, KeyError, ValueError):
            self.rise_time = 0  # ms
        try:
            self.fall_time = init_dict['fall_time']
        except (TypeError, KeyError, ValueError):
            self.fall_time = 0  # ms

        self.amp_text = wx.TextCtrl(parent, -1, '%d' % self.amp,
                                    style=wx.TE_PROCESS_ENTER)
        self.amp_text.SetToolTip(
            'Range: 0~255\u03bcA, Precision: \u00b10.5\u03bcA')
        self.amp_text.Bind(wx.EVT_KILL_FOCUS, self.on_amp)
        self.amp_text.Bind(wx.EVT_TEXT_ENTER, self.on_amp)
        self.Add(self.amp_text, 0, wx.EXPAND)
        self.period_text = wx.TextCtrl(parent, -1, '%.2f' % self.period,
                                       style=wx.TE_PROCESS_ENTER)
        self.period_text.SetToolTip(
            'Precision: \u00b10.08ms')
        self.period_text.Bind(wx.EVT_KILL_FOCUS, self.on_period)
        self.period_text.Bind(wx.EVT_TEXT_ENTER, self.on_period)
        self.Add(self.period_text, 0, wx.EXPAND)
        self.pw_text = wx.TextCtrl(parent, -1, '%.2f' % self.pulse_width,
                                   style=wx.TE_PROCESS_ENTER)
        self.pw_text.SetToolTip(
            'Range: 0~period, Precision: \u00b10.08ms')
        self.pw_text.Bind(wx.EVT_KILL_FOCUS, self.on_pulse_width)
        self.pw_text.Bind(wx.EVT_TEXT_ENTER, self.on_pulse_width)
        self.Add(self.pw_text, 0, wx.EXPAND)
        self.rise_time_text = wx.TextCtrl(parent, -1, '%.2f' % self.rise_time,
                                          style=wx.TE_PROCESS_ENTER)
        self.rise_time_text.SetToolTip(
            'Precision: \u00b10.08ms')
        self.rise_time_text.Bind(wx.EVT_KILL_FOCUS, self.on_rise_time)
        self.rise_time_text.Bind(wx.EVT_TEXT_ENTER, self.on_rise_time)
        self.Add(self.rise_time_text, 0, wx.EXPAND)
        self.fall_time_text = wx.TextCtrl(parent, -1, '%.2f' % self.fall_time,
                                          style=wx.TE_PROCESS_ENTER)
        self.fall_time_text.SetToolTip(
            'Precision: \u00b10.08ms')
        self.fall_time_text.Bind(wx.EVT_KILL_FOCUS, self.on_fall_time)
        self.fall_time_text.Bind(wx.EVT_TEXT_ENTER, self.on_fall_time)
        self.Add(self.fall_time_text, 0, wx.EXPAND)

        self.modify_callback = modify_callback

    def get_waveform(self) -> galvani.SquareWaveform:
        return galvani.SquareWaveform(amp=self.amp,
                                      pulse_width=self.pulse_width / 1000,
                                      period=self.period / 1000,
                                      rising_time=self.rise_time / 1000,
                                      falling_time=self.fall_time / 1000)

    def to_dict(self):
        return {'amp': self.amp, 'pulse_width': self.pulse_width,
                'period': self.period, 'rise_time': self.rise_time, 'fall_time': self.fall_time}

    def on_amp(self, event: wx.Event):
        try:
            val = float(self.amp_text.GetValue())
        except ValueError:
            self.amp_text.SetValue(str(self.amp))
            event.Skip()
            return
        val = 0 if val < 0 else 255 if val > 255 else round(val)
        if self.amp != val:
            self.amp = val
            self.modify_callback()
        self.amp_text.SetValue('%d' % self.amp)
        event.Skip()

    def on_pulse_width(self, event: wx.Event):
        try:
            val = float(self.pw_text.GetValue())
        except ValueError:
            self.pw_text.SetValue(str(self.pulse_width))
            event.Skip()
            return
        if val > self.period:
            val = self.period
        val = round(val,2) if val > 0 else 0
        if self.pulse_width != val:
            self.pulse_width = val
            self.modify_callback()
        self.pw_text.SetValue('%.2f' % self.pulse_width)
        event.Skip()

    def on_period(self, event: wx.Event):
        try:
            val = float(self.period_text.GetValue())
        except ValueError:
            self.period_text.SetValue('%.2f' % self.period)
            event.Skip()
            return
        val = round(val,2) if val > 0 else 0
        if self.period != val:
            self.period = val
            if val < self.pulse_width:
                self.pulse_width = val
                self.pw_text.SetValue('%.2f' % self.pulse_width)
            self.modify_callback()
        self.period_text.SetValue('%.2f' % self.period)
        event.Skip()

    def on_rise_time(self, event: wx.Event):
        try:
            val = float(self.rise_time_text.GetValue())
        except ValueError:
            self.rise_time_text.SetValue('%.2f' % self.rise_time)
            event.Skip()
            return
        val = round(val,2) if val > 0 else 0
        if self.rise_time != val:
            self.rise_time = val
            self.modify_callback()
        self.rise_time_text.SetValue('%.2f' % self.rise_time)
        event.Skip()

    def on_fall_time(self, event: wx.Event):
        try:
            val = float(self.fall_time_text.GetValue())
        except ValueError:
            self.fall_time_text.SetValue('%.2f' % self.fall_time)
            event.Skip()
            return
        val = round(val,2) if val > 0 else 0
        if self.fall_time != val:
            self.fall_time = val
            self.modify_callback()
        self.fall_time_text.SetValue('%.2f' % self.fall_time)
        event.Skip()


class CustomWavePanel(wx.FlexGridSizer):
    def __init__(self, parent, modify_callback, init_dict=None):
        wx.FlexGridSizer.__init__(self, 2, 2, 5, 5)
        self.AddGrowableCol(0, 4)
        self.AddGrowableCol(1, 1)
        self.Add(wx.StaticText(parent, -1, 'Custom Waveform File'), 0,
                 wx.EXPAND)
        self.Add(wx.StaticText(parent, -1, 'Sample Rate (Sa/s)'), 0, wx.EXPAND)

        self.wave = []
        try:
            self.sample_rate = init_dict['sample_rate']
        except (TypeError, KeyError, ValueError):
            self.sample_rate = 1000  # Sample/s

        self.file_picker = wx.FilePickerCtrl(parent, -1, wildcard='*.cwave')
        self.file_picker.Bind(wx.EVT_FILEPICKER_CHANGED, self.on_file)
        self.Add(self.file_picker, 0, wx.EXPAND)
        self.sample_rate_text = wx.TextCtrl(parent, -1, '%f' % self.sample_rate,
                                          style=wx.TE_PROCESS_ENTER)
        self.sample_rate_text.SetToolTip(
            'Range: 0~13kSa/s')
        self.sample_rate_text.Bind(wx.EVT_KILL_FOCUS, self.on_sample_rate)
        self.sample_rate_text.Bind(wx.EVT_TEXT_ENTER, self.on_sample_rate)
        self.Add(self.sample_rate_text, 0, wx.EXPAND)

        self.modify_callback = modify_callback

    def on_file(self, event: wx.Event):
        with open(self.file_picker.GetPath()) as fp:
            self.wave = [float(x) for x in fp.read().split()]

    def on_sample_rate(self, event: wx.Event):
        try:
            val = float(self.sample_rate_text.GetValue())
        except ValueError:
            self.sample_rate_text.SetValue('%f' % self.sample_rate)
            event.Skip()
            return
        val = val if val > 0 else 0
        if self.sample_rate != val:
            self.sample_rate = val
            self.modify_callback()
        self.sample_rate_text.SetValue('%f' % self.sample_rate)
        event.Skip()

    def get_waveform(self) -> galvani.CustomWaveform:
        return galvani.CustomWaveform(self.wave, self.sample_rate)


class WaveFormPanel(wx.StaticBoxSizer):
    def __init__(self, parent, label, modify_callback, init_dict=None):
        wx.StaticBoxSizer.__init__(self, wx.VERTICAL, parent, label)
        p = self.GetStaticBox()
        font = wx.Font(wx.FontInfo(10).Bold())
        self.label = label
        common = wx.BoxSizer(wx.HORIZONTAL)
        wf_types = ['Square / Trapezoid', 'Custom']
        self.waveform_type_choice = wx.Choice(p, -1, choices=wf_types)
        try:
            sel = wf_types.index(init_dict['type'])
        except (TypeError, KeyError, ValueError):
            sel = 0
        self.waveform_type_choice.SetSelection(sel)
        self.waveform_type_choice.Bind(wx.EVT_CHOICE, self.on_type)
        common.Add(LabeledCtrl(self.waveform_type_choice, p,
                               -1, 'Waveform Type'), 0, wx.ALL, 3)
        try:
            n_pulses = int(init_dict['n_pulses'])
            n_pulses = (1 if n_pulses < 1 else
                        0xffff if n_pulses > 0xffff else n_pulses)
        except (TypeError, KeyError, ValueError):
            n_pulses = 1
        self.num_of_pulses = wx.SpinCtrl(p, -1, min=1, max=0xffff,
                                         value=str(n_pulses),
                                         style=wx.TE_PROCESS_ENTER)
        self.num_of_pulses.Bind(wx.EVT_SPINCTRL,
                                lambda _: modify_callback(self.label))
        self.num_of_pulses.Bind(wx.EVT_TEXT_ENTER, self.on_num_of_pulses)
        self.num_of_pulses.SetToolTip('Range: 1~65535')

        common.Add(
            LabeledCtrl(self.num_of_pulses, p, -1, 'Number of Pulses'),
            0, wx.ALL, 3)
        common.AddStretchSpacer(1)
        preview_button = wx.Button(p, -1, 'Preview', style=wx.BU_EXACTFIT)
        preview_button.Bind(wx.EVT_BUTTON, self.on_preview)
        common.Add(preview_button, 0, wx.ALIGN_TOP | wx.ALL, 3)
        self.delete_button = wx.Button(p, -1, 'X', style=wx.BU_EXACTFIT)
        self.delete_button.SetToolTip(wx.ToolTip('Delete waveform'))
        common.Add(self.delete_button, 0, wx.ALIGN_TOP | wx.ALL, 3)
        self.Add(common, 0, wx.EXPAND)
        self.p_square = SquareWavePanel(p, lambda: modify_callback(self.label),
                                        init_dict=init_dict)
        self.p_custom = CustomWavePanel(p, lambda: modify_callback(self.label), init_dict=init_dict)
        self.Add(self.p_square, 0, wx.EXPAND | wx.ALL, 3)
        self.Add(self.p_custom, 0, wx.EXPAND | wx.ALL, 3)
        self.Hide(self.p_custom)
        # self.Layout()
        self.detail = self.p_square
        self.modify_callback = modify_callback
        p.SetFont(font)

    def on_num_of_pulses(self, event: wx.Event):
        self.num_of_pulses.SetValue(self.num_of_pulses.GetValue())
        self.modify_callback(self.label)
        event.Skip()

    def channel_info(self, n_pulses=None):
        wf = self.detail.get_waveform()
        if n_pulses is None:
            n_pulses = self.num_of_pulses.GetValue()
        if isinstance(wf, galvani.SquareWaveform):
            return galvani.GetChannelInfoSquare(n_pulses, wf.rising_time, wf.amp, wf.pulse_width,
                                                wf.period, wf.falling_time)
        elif isinstance(wf, galvani.CustomWaveform):
            wf_data = np.array(wf.wave, dtype=np.uint8).tobytes()
            return galvani.GetChannelInfoCustom(n_pulses, wf_data, len(wf_data), wf.sample_rate)

    def to_dict(self) -> dict:
        ret = {'label': self.label,
               'type': self.waveform_type_choice.GetStringSelection(),
               'n_pulses': self.num_of_pulses.GetValue()}
        ret.update(self.detail.to_dict())
        return ret

    def on_preview(self, event: wx.Event):
        n_pulses = self.num_of_pulses.GetValue()
        wf = self.detail.get_waveform()
        if isinstance(wf, galvani.SquareWaveform):
            if wf.period <= 0:
                wx.MessageBox(
                    'Error: invalid period %d. Period should be positive.' % wf.period,
                    'Preview for ' + self.label)
                return
            else:
                xs = [0]
                ys = [0]
                for i in range(n_pulses):
                    x_offset = xs[-1]
                    if wf.pulse_width == 0:
                        xs.append(x_offset + wf.period * 1000)
                        ys.append(0)
                    elif wf.rising_time + wf.falling_time < wf.pulse_width:
                        xs.extend((x_offset + wf.rising_time * 1000,
                                   x_offset + (wf.pulse_width - wf.falling_time) * 1000,
                                   x_offset + wf.pulse_width * 1000,
                                   x_offset + wf.period * 1000))
                        ys.extend((wf.amp, wf.amp, 0, 0))
                    else:
                        xs.extend((x_offset + wf.rising_time * wf.pulse_width / (wf.rising_time + wf.falling_time) * 1000,
                                   x_offset + wf.pulse_width * 1000,
                                   x_offset + wf.period * 1000))
                        ys.extend((wf.amp * wf.pulse_width / (wf.rising_time + wf.falling_time), 0, 0))
        elif isinstance(wf, galvani.CustomWaveform):
            if not wf.wave:
                wx.MessageBox(
                    'Error: invalid custom waveform.',
                    'Preview for ' + self.label)
                return
            else:
                xs = np.arange(len(wf.wave) * n_pulses) / wf.sample_rate * 1000
                ys = wf.wave * n_pulses
        else:
            raise TypeError('Waveform type not supported')
        plt.figure(num='Preview for ' + self.label)
        plt.plot(xs, ys, label=self.label)
        plt.xlabel('time (ms)')
        plt.ylabel('amplitude (\u03bcA)')
        plt.show()

    def on_type(self, event: wx.Event):
        obj = event.GetEventObject()
        assert isinstance(obj, wx.Choice)
        if obj.GetSelection() == 0:  # Square Wave
            self.Hide(self.p_custom)
            self.Show(self.p_square)
            self.Layout()
            self.detail = self.p_square
        else:
            self.Hide(self.p_square)
            self.Show(self.p_custom)
            self.Layout()
            self.detail = self.p_custom
        self.modify_callback(self.label)


class WaveformManager(wx.ScrolledWindow):
    def __init__(self, parent, mf, ident=-1):
        wx.ScrolledWindow.__init__(self, parent, ident,
                                   style=wx.VSCROLL | wx.ALWAYS_SHOW_SB)
        self.box = wx.BoxSizer(wx.VERTICAL)

        new_wf = wx.Button(self, -1, 'Add New Waveform')
        new_wf.Bind(wx.EVT_BUTTON, self.on_new_wf)

        self.box.Add(new_wf, wx.SizerFlags().Right())

        self.cnt = 4
        self.waveform_panels = [WaveFormPanel(self, 'Waveform %d' % (x + 1),
                                              mf.set_wf_modified)
                                for x in range(self.cnt)]
        for wf in self.waveform_panels:
            self.box.Add(wf, 0, wx.EXPAND | wx.TOP | wx.BOTTOM, 5)

        self.SetSizerAndFit(self.box)
        # self.box.SetSizeHints(self)
        self.SetScrollRate(5, 5)

        self.Bind(wx.EVT_BUTTON, self.on_delete)
        self.parent = parent
        self.mf = mf

    def on_delete(self, event: wx.Event):
        ident = event.GetId()
        obj = event.GetEventObject()
        assert isinstance(obj, wx.Button)
        for idx, x in enumerate(self.waveform_panels):
            if ident == x.delete_button.GetId():
                ch = self.mf.is_wf_using(idx)
                if ch is not None:
                    wx.MessageBox(
                        'Cannot delete waveform.\n'
                        'Waveform is being used by %s.' % ch,
                        'Error', wx.ICON_ERROR | wx.OK | wx.CENTRE, self.mf)
                    return
                self.parent.Freeze()
                del self.waveform_panels[idx]
                self.box.Detach(x)
                x.GetStaticBox().DestroyChildren()
                x.Destroy()
                break
        self.mf.update_wf_list()
        self.parent.Layout()
        self.parent.Thaw()

    def from_dict(self, d: List[dict]):
        self.parent.Freeze()
        for x in self.waveform_panels:
            self.box.Detach(x)
            x.GetStaticBox().DestroyChildren()
            x.Destroy()
        self.waveform_panels = []
        self.cnt = 0
        for x in d:
            # FIXME: get the cnt the dirty way
            if x['label'].startswith('Waveform '):
                try:
                    self.cnt = max(self.cnt, int(x['label'][9:]))
                except ValueError:
                    pass
            wf = WaveFormPanel(self, x['label'], self.mf.set_wf_modified,
                               init_dict=x)
            self.waveform_panels.append(wf)
            self.box.Add(wf, 0, wx.EXPAND | wx.TOP | wx.BOTTOM, 5)
        self.box.SetSizeHints(self)
        self.mf.update_wf_list()
        self.parent.Layout()
        self.parent.Thaw()

    def on_new_wf(self, event: wx.Event):
        self.parent.Freeze()
        self.cnt += 1
        wf = WaveFormPanel(
            self, 'Waveform %d' % self.cnt, self.mf.set_wf_modified)
        self.waveform_panels.append(wf)
        self.box.Add(wf, 0, wx.EXPAND | wx.TOP | wx.BOTTOM, 5)
        self.box.SetSizeHints(self)
        self.mf.update_wf_list()
        self.parent.Layout()
        self.parent.Thaw()


class MainFrame(wx.Frame):
    def __init__(self, parent=None, ident=-1):
        wx.Frame.__init__(
            self, parent, ident,
            'Galvani Stimulate GUI v' + __version__)
        self.device = None
        self.devices = {}

        self.board_relative_controls = []

        p = wx.Panel(self, -1)
        self.p = p

        # Setup frame
        setup_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, p, 'Setup')
        self.device_choice = wx.TextCtrl(p, -1, galgui_config['GalGUI']['device_name'])
        self.device_choice.SetToolTip('You can find the interface name in NI MAX. Prepend that name with a "/"')
        self.connect_button = wx.Button(p, -1, 'Connect')
        self.connect_button.Bind(wx.EVT_BUTTON, lambda _: self.on_connect())
        setup_sizer.Add(LabeledCtrl(self.device_choice, p, -1,
                                    'Enter your NI interface name'),
                        0, wx.EXPAND | wx.ALL, 3)
        setup_sizer.AddStretchSpacer(1)
        setup_sizer.Add(self.connect_button, 0, wx.EXPAND | wx.ALL, 3)

        left_box = wx.BoxSizer(wx.VERTICAL)
        left_box.Add(setup_sizer, 0, wx.EXPAND)

        # Config frame
        config_sizer = wx.StaticBoxSizer(wx.HORIZONTAL, p,
                                         'Waveform and Channel Config')
        config_sizer.AddStretchSpacer(1)
        save_config_button = wx.Button(p, -1, 'Save config to file')
        save_config_button.Bind(wx.EVT_BUTTON, self.on_save_config)
        config_sizer.Add(save_config_button, wx.SizerFlags().Expand())
        config_sizer.AddStretchSpacer(1)
        load_config_button = wx.Button(p, -1, 'Load config from file')
        load_config_button.Bind(wx.EVT_BUTTON, self.on_load_config)
        config_sizer.Add(load_config_button, wx.SizerFlags().Expand())
        config_sizer.AddStretchSpacer(1)

        left_box.Add(config_sizer, wx.SizerFlags().Expand())
        left_box.AddSpacer(30)

        self.wfm = WaveformManager(p, self)
        left_box.Add(self.wfm, 1, wx.EXPAND)

        channels_ui = []
        self.channels_ui = channels_ui
        if galgui_config['GalGUI']['show_all_channels'] == 'yes':
            channel_panel = wx.Notebook(p)
            channel_map = {'Shank 1 (1/2)':[108,115,109,114,110,113,111,112,104,119,105,118,106,117,107,116],'Shank 1 (2/2)':[100,123,101,122,102,121,103,120,96,127,97,126,98,125,99,124],'Shank 2 (1/2)':[80,79,81,78,82,77,83,76,84,75,85,74,86,73,87,72],'Shank 2 (2/2)':[88,71,89,70,90,69,91,68,92,67,93,66,94,65,95,64],'Shank 3 (1/2)':[15,16,14,17,13,18,12,19,11,20,10,21,9,22,8,23],'Shank 3 (2/2)':[7,24,6,25,5,26,4,27,3,28,2,29,1,30,0,31],'Shank 4 (1/2)':[51,44,50,45,49,46,48,47,55,40,54,41,53,42,52,43],'Shank 4 (2/2)':[59,36,58,37,57,38,56,39,63,32,62,33,61,34,60,35]}
            for text, chs in channel_map.items():
                page_panel = wx.Panel(channel_panel)
                channel_box = wx.FlexGridSizer(17, 7, 5, 5)
                channel_box.AddGrowableCol(5, 1)
                channel_box.Add(wx.StaticText(page_panel, -1, 'Channel #'), 0, wx.ALIGN_CENTER)
                channel_box.Add(wx.StaticText(page_panel, -1, 'Waveform'), 0, wx.ALIGN_CENTER)
                channel_box.Add(wx.StaticText(page_panel, -1, 'Mode'), 0,
                                wx.ALIGN_CENTER)
                channel_box.Add(wx.StaticText(page_panel, -1, 'Trigger'), 0,
                                wx.ALIGN_CENTER)
                channel_box.Add(wx.StaticText(page_panel, -1, 'Stop'), 0,
                                wx.ALIGN_CENTER)
                channel_box.Add(wx.StaticText(page_panel, -1, 'Status'), 0, wx.ALIGN_CENTER)
                channel_box.AddSpacer(0)
                for ch in chs:
                    self.add_channel(ch, 'Channel %d' % ch, channel_box, channels_ui, page_panel)
                page_panel.SetSizerAndFit(channel_box)
                channel_panel.AddPage(page_panel, text)

        else:
            channel_panel = wx.StaticBoxSizer(wx.VERTICAL, p)
            channel_box = wx.FlexGridSizer(7, 5, 5)
            self.channel_box = channel_box
            channel_box.Add(wx.StaticText(p, -1, 'Channel #'), 0, wx.ALIGN_CENTER)
            channel_box.Add(wx.StaticText(p, -1, 'Waveform'), 0, wx.ALIGN_CENTER)
            channel_box.Add(wx.StaticText(p, -1, 'Mode'), 0,
                            wx.ALIGN_CENTER)
            channel_box.Add(wx.StaticText(p, -1, 'Trigger'), 0,
                            wx.ALIGN_CENTER)
            channel_box.Add(wx.StaticText(p, -1, 'Stop'), 0,
                            wx.ALIGN_CENTER)
            channel_box.Add(wx.StaticText(p, -1, 'Status'), 0, wx.ALIGN_CENTER)
            channel_box.Add(wx.StaticText(p, -1, 'Del'), 0, wx.ALIGN_CENTER)
            channel_box.AddGrowableCol(5, 1)
            for i in range(12):
                self.add_channel(i, 'Channel %d' % i, channel_box, channels_ui, p)
            channel_panel.Add(channel_box, 1, wx.EXPAND)

        right_box = wx.BoxSizer(wx.VERTICAL)
        right_box.Add(channel_panel, 0, wx.EXPAND | wx.BOTTOM, 5)

        extra_buttons = wx.BoxSizer(wx.HORIZONTAL)

        if galgui_config['Waveform']['realtime_update'] != 'yes':
            update_all = wx.Button(p, -1, 'Update all channel parameters')
            update_all.SetToolTip(
                'This will update all waveform parameters, '
                'trigger source, and trigger mode for all modified channel(s).'
                '\nModified channel(s) are marked with asterisk.')
            update_all.Bind(wx.EVT_BUTTON, self.on_update)
            extra_buttons.Add(update_all)
            self.board_relative_controls.append(update_all)

        trigger_all = wx.Button(p, -1, 'Trigger All')
        trigger_all.Bind(wx.EVT_BUTTON,
                         lambda _: [x.on_trigger(None) for x in self.channels_ui])
        extra_buttons.Add(trigger_all)
        self.board_relative_controls.append(trigger_all)

        if galgui_config['GalGUI']['show_all_channels'] != 'yes':
            add_channel = wx.Button(p, -1, 'Add Channel')
            add_channel.Bind(wx.EVT_BUTTON, self.on_add_channel)
            extra_buttons.Add(add_channel)

        right_box.Add(extra_buttons, 0, wx.EXPAND | wx.BOTTOM, 20)

        log_text = wx.TextCtrl(p, -1, style=wx.TE_MULTILINE | wx.TE_READONLY)
        self.log_sh = logging.StreamHandler(log_text)
        self.log_sh.setLevel(logging.DEBUG if galgui_config['GalGUI']['verbose_log'] == 'yes' else logging.INFO)
        self.formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        self.log_sh.setFormatter(self.formatter)
        logging.getLogger().addHandler(self.log_sh)
        log_box = wx.StaticBoxSizer(wx.VERTICAL, p, 'Log')
        log_box.Add(log_text, 1, wx.EXPAND)

        log_options_sizer = wx.BoxSizer(wx.HORIZONTAL)
        log_options_sizer.AddStretchSpacer(1)

        verbose_log_checkbox = wx.CheckBox(p, -1, 'Enable verbose logging')
        verbose_log_checkbox.Bind(wx.EVT_CHECKBOX, self.on_verbose_log)
        save_log_checkbox = wx.CheckBox(p, -1, 'Save log to file')
        save_log_checkbox.Bind(wx.EVT_CHECKBOX, self.on_save_log)

        if galgui_config['GalGUI']['save_log_to_file'] == 'yes':
            save_log_checkbox.SetValue(True)
            self.log_fh = logging.FileHandler(
                time.strftime('oscgui-%Y%m%d.log'), delay=True)
            self.log_fh.setLevel(logging.DEBUG if galgui_config['GalGUI']['verbose_log'] == 'yes' else logging.INFO)
            self.log_fh.setFormatter(self.formatter)
            logging.getLogger().addHandler(self.log_fh)
        else:
            self.log_fh = None
        verbose_log_checkbox.SetValue(galgui_config['GalGUI']['verbose_log'] == 'yes')

        clear_log_button = wx.Button(p, -1, 'Clear Log')
        clear_log_button.Bind(wx.EVT_BUTTON, lambda _: log_text.Clear())
        log_options_sizer.Add(verbose_log_checkbox, wx.SizerFlags().Expand())
        log_options_sizer.Add(save_log_checkbox, wx.SizerFlags().Expand())
        log_options_sizer.Add(clear_log_button, wx.SizerFlags().Expand())
        log_box.Add(log_options_sizer, wx.SizerFlags().Expand())
        right_box.Add(log_box, 1, wx.EXPAND)

        box = wx.BoxSizer(wx.HORIZONTAL)
        box.Add(left_box, 0, wx.EXPAND | wx.ALL, 5)
        box.AddSpacer(20)
        box.Add(right_box, 1, wx.EXPAND | wx.ALL, 5)

        for x in self.board_relative_controls:
            x.Disable()

        p.SetSizerAndFit(box)
        self.Fit()
        self.Bind(wx.EVT_CLOSE, self.on_close)
        self.Bind(wx.EVT_IDLE, self.on_idle)

    def on_save_log(self, event: wx.Event):
        obj = event.GetEventObject()
        assert isinstance(obj, wx.CheckBox)
        if obj.GetValue():
            galgui_config['GalGUI']['save_log_to_file'] = 'yes'
            with open('config.ini', 'w') as fp:
                galgui_config.write(fp)
            if self.log_fh is None:
                self.log_fh = logging.FileHandler(
                    time.strftime('oscgui-%Y%m%d.log'), delay=True)
                self.log_fh.setLevel(logging.INFO)
                self.log_fh.setFormatter(self.formatter)
                logging.getLogger().addHandler(self.log_fh)

        else:
            galgui_config['GalGUI']['save_log_to_file'] = 'no'
            with open('config.ini', 'w') as fp:
                galgui_config.write(fp)
            if self.log_fh:
                logging.getLogger().removeHandler(self.log_fh)
                self.log_fh.close()
                self.log_fh = None

    def on_verbose_log(self, event: wx.Event):
        obj = event.GetEventObject()
        assert isinstance(obj, wx.CheckBox)
        if obj.GetValue():
            galgui_config['GalGUI']['verbose_log'] = 'yes'
            with open('config.ini', 'w') as fp:
                galgui_config.write(fp)
            self.log_sh.setLevel(logging.DEBUG)
            if self.log_fh is not None:
                self.log_fh.setLevel(logging.DEBUG)

        else:
            galgui_config['GalGUI']['verbose_log'] = 'no'
            with open('config.ini', 'w') as fp:
                galgui_config.write(fp)
            self.log_sh.setLevel(logging.INFO)
            if self.log_fh is not None:
                self.log_fh.setLevel(logging.INFO)

    def on_update(self, event: wx.Event):
        chs = [x.ch for x in self.channels_ui if x.modified]
        if chs:
            if self.device is not None:
                for ch in chs:
                    galvani.GalvaniDeviceSetChannel(self.device, ch, galvani.ffi.NULL)
            for x in self.channels_ui:
                if x.modified:
                    x.update_param()
            if galgui_config['Waveform']['realtime_update'] != 'yes':
                logging.getLogger('GalGUI').info(
                    'Waveform updated: %s',
                    ', '.join(self.channels_ui[ch].channel_name for ch in chs))
        elif galgui_config['Waveform']['realtime_update'] != 'yes':
            logging.getLogger('GalGUI').info(
                'Channels already up to date')

    def on_connect(self, connect=None):
        if connect is None:
            connect = self.connect_button.GetLabel() == 'Connect'
        if connect:
            if self.device is not None:
                return
            device_name = self.device_choice.GetValue()
            galgui_config['GalGUI']['device_name'] = device_name
            with open('config.ini', 'w') as fp:
                galgui_config.write(fp)
            device_name = device_name.encode()
            self.device = galvani.GetGalvaniDevice(device_name, len(device_name))
            galvani.StartGalvaniDevice(self.device)
            self.Freeze()
            for x in self.channels_ui:
                x.set_modified()
                x.on_connect()
            self.device_choice.Disable()
            self.connect_button.SetLabel('Disconnect')
            for x in self.board_relative_controls:
                x.Enable()
            logging.getLogger('GalGUI').info('Connected')
            if galgui_config['Waveform']['realtime_update'] == 'yes':
                self.on_update(None)
            self.Thaw()
        else:
            if self.device is None:
                return
            galvani.StopGalvaniDevice(self.device)
            self.device = None
            self.Freeze()
            self.device_choice.Enable()
            self.connect_button.SetLabel('Connect')
            for x in self.channels_ui:
                x.on_disconnect()
            for x in self.board_relative_controls:
                x.Disable()
            logging.getLogger('GalGUI').info('Disconnected')
            self.Thaw()

    def on_idle(self, event: wx.IdleEvent):
        if self.device is not None:
            status_array = galvani.ffi.new('bool[128]')
            error = galvani.GalvaniDeviceGetStatus(self.device, status_array)
            if error:
                logging.getLogger('GalGUI').error('Unexpected error. Check DAQerr.txt for more info.')
                self.on_connect(False)
                event.RequestMore()
                return
            for x in self.channels_ui:
                x.update_status(status_array[x.ch])
            event.RequestMore()

    def is_wf_using(self, wf_index: int):
        for x in self.channels_ui:
            wf = x.waveform_choice.GetSelection()
            if wf_index == wf:
                return x.channel_name
        return None

    def set_wf_modified(self, waveform: str):
        self.Freeze()
        for ch, x in enumerate(self.channels_ui):
            wf = x.waveform_choice.GetStringSelection()
            if waveform == wf:
                x.set_modified()
        if galgui_config['Waveform']['realtime_update'] == 'yes':
            self.on_update(None)
        self.Thaw()

    def update_wf_list(self):
        self.Freeze()
        wfs = [x.label for x in self.wfm.waveform_panels]
        for x in self.channels_ui:
            wf = x.waveform_choice.GetStringSelection()
            x.waveform_choice.Set(wfs)
            x.waveform_choice.SetSelection(wfs.index(wf))
        self.Thaw()

    def on_close(self, event: wx.CloseEvent):
        self.on_connect(False)
        event.Skip()

    def on_save_config(self, event: wx.Event):
        with wx.FileDialog(self, "Save config file",
                           wildcard="JSON config files (*.json)|*.json",
                           style=wx.FD_SAVE | wx.FD_OVERWRITE_PROMPT) as fd:
            if fd.ShowModal() == wx.ID_CANCEL:
                return
            pathname = fd.GetPath()
            try:
                with open(pathname, 'w') as fp:
                    config = {'__version__': __version__,
                              'waveforms': [x.to_dict()
                                            for x in self.wfm.waveform_panels],
                              'channels': [x.to_dict()
                                           for x in self.channels_ui]}
                    json.dump(config, fp, separators=(',', ':'))
                    logging.getLogger('GalGUI').info(
                        'Saved config file to ' + pathname)
            except IOError:
                logging.getLogger('GalGUI').warning(
                    'Failed to save config file')

    def on_load_config(self, event: wx.Event):
        with wx.FileDialog(self, "Load config file",
                           wildcard="JSON config files (*.json)|*.json",
                           style=wx.FD_OPEN | wx.FD_FILE_MUST_EXIST) as fd:
            if fd.ShowModal() == wx.ID_CANCEL:
                return
            pathname = fd.GetPath()
            self.Freeze()
            try:
                with open(pathname, 'r') as fp:
                    config = json.load(fp)
                if config['__version__'] != __version__:
                    raise ValueError('Config file has incompatible version (config version: ' + config[
                        '__version__'] + ', software version: ' + __version__ + ')')
                self.wfm.from_dict(config['waveforms'])
                if galgui_config['GalGUI']['show_all_channels'] == 'yes':
                    for x in config['channels']:
                        for y in self.channels_ui:
                            if y.ch == x['ch']:
                                y.from_dict(x)
                else:
                    self.Freeze()
                    while self.channels_ui:
                        self.channels_ui[0].on_del(None)
                    for x in config['channels']:
                        self.add_channel(x['ch'], x['channel_name'], self.channel_box, self.channels_ui, self.p)
                    self.p.Layout()
                    self.Thaw()
                for x, y in zip(self.channels_ui, config['channels']):
                    x.from_dict(y)
            except (IOError, ValueError, KeyError, AssertionError) as e:
                logging.getLogger('GalGUI').error(
                    'Failed to load config file: ' + str(e))
            if galgui_config['Waveform']['realtime_update'] == 'yes':
                self.on_update(None)
            self.Thaw()

    def add_channel(self, ch: int, name: str, channel_box, channels_ui, p):
        sizers = []
        channel_label = wx.StaticText(p, -1, name)
        channel_box.Add(channel_label, 0, wx.ALIGN_CENTER)

        waveform_choice = wx.Choice(p, -1,
                                    choices=['Waveform %d' % (x + 1) for x
                                             in range(4)])
        waveform_choice.SetSelection(0)
        wrap_box = wx.BoxSizer(wx.HORIZONTAL)
        wrap_box.Add(waveform_choice, 1, wx.ALIGN_CENTER_VERTICAL)
        channel_box.Add(wrap_box, 0, wx.EXPAND)
        sizers.append(wrap_box)

        continuous_toggle = wx.ToggleButton(p, -1, 'One-shot')
        wrap_box = wx.BoxSizer(wx.HORIZONTAL)
        wrap_box.Add(continuous_toggle, 1, wx.ALIGN_CENTER_VERTICAL)
        channel_box.Add(wrap_box, 0, wx.EXPAND)
        sizers.append(wrap_box)

        trigger_button = wx.Button(p, -1, 'Trigger', style=wx.BU_EXACTFIT)
        wrap_box = wx.BoxSizer(wx.HORIZONTAL)
        wrap_box.Add(trigger_button, 1, wx.ALIGN_CENTER_VERTICAL)
        channel_box.Add(wrap_box, 0, wx.EXPAND)
        sizers.append(wrap_box)

        stop_button = wx.Button(p, -1, 'Stop', style=wx.BU_EXACTFIT)
        wrap_box = wx.BoxSizer(wx.HORIZONTAL)
        wrap_box.Add(stop_button, 1, wx.ALIGN_CENTER_VERTICAL)
        channel_box.Add(wrap_box, 0, wx.EXPAND)
        sizers.append(wrap_box)

        status_text = wx.TextCtrl(p, -1, 'Board not connected',
                                  style=wx.TE_READONLY)
        wrap_box = wx.BoxSizer(wx.HORIZONTAL)
        wrap_box.Add(status_text, 1, wx.ALIGN_CENTER_VERTICAL)
        channel_box.Add(wrap_box, 0, wx.EXPAND | wx.LEFT, 5)
        sizers.append(wrap_box)

        del_button = wx.Button(p, -1, 'X',
                               style=wx.BU_EXACTFIT)
        if galgui_config['GalGUI']['show_all_channels'] == 'yes':
            del_button.Hide()
        wrap_box = wx.BoxSizer(wx.HORIZONTAL)
        wrap_box.Add(del_button, 1, wx.ALIGN_CENTER_VERTICAL)
        channel_box.Add(wrap_box, 0, wx.EXPAND | wx.LEFT, 5)
        sizers.append(wrap_box)

        channel = ChannelCtrl(
            ch, channel_label, waveform_choice,
            continuous_toggle, trigger_button, stop_button,
            status_text, del_button, sizers, self)
        if self.connect_button.GetLabel() == 'Connect':
            channel.on_disconnect()
        else:
            channel.on_connect()
        channels_ui.append(channel)

    def on_add_channel(self, event: wx.Event):
        ch_dialog = wx.TextEntryDialog(self, "Enter the channel you want to add: (0 - 127)")
        if ch_dialog.ShowModal() == wx.ID_OK:
            try:
                ch = int(ch_dialog.GetValue())
                if 0 <= ch < 128:
                    for x in self.channels_ui:
                        if ch == x.ch:
                            logging.getLogger('GalGUI').error('Add Channel failed, channel existed: %s',
                                                              ch_dialog.GetValue())
                            return
                    self.Freeze()
                    self.add_channel(ch, 'Channel %d' % ch, self.channel_box, self.channels_ui, self.p)
                    self.p.Layout()
                    self.Thaw()
                else:
                    logging.getLogger('GalGUI').error('Add Channel failed, channel number out of range: %s',
                                                      ch_dialog.GetValue())
            except ValueError:
                logging.getLogger('GalGUI').error('Add Channel failed, not an integer: %s', ch_dialog.GetValue())


if __name__ == '__main__':
    app = wx.App()
    MainFrame().Show()
    sys.exit(app.MainLoop())
