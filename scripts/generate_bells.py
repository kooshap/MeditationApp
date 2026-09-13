#!/usr/bin/env python3
"""Synthesizes the five bell sounds into MeditationApp/Resources/ as CAF files.

Each bell is additive synthesis: decaying sine partials at the (inharmonic)
frequency ratios of the real instrument, slow beating between detuned twins,
and a short filtered-noise transient for the mallet strike. Output is
deterministic (fixed seed), so re-running reproduces identical files.

Files are 16-bit PCM CAF so the same sound works for in-app playback and as a
local notification sound (notifications only accept aiff, wav, or caf).

Requires: pip install numpy
Usage:    python3 scripts/generate_bells.py
"""
import os
import struct

import numpy as np

SR = 44100
TARGET_RMS = 0.25   # loudness match over the first 1.5s of each bell
PEAK = 0.89         # ≈ -1 dBFS ceiling
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "MeditationApp", "Resources")

rng = np.random.default_rng(7)


def t_axis(dur):
    return np.arange(int(SR * dur)) / SR


def partial(t, freq, amp, decay, attack=0.002, beat=0.0, depth=0.0):
    """Exponentially decaying sine; `beat` adds a detuned twin for the wobble of real metal."""
    tone = np.sin(2 * np.pi * freq * t + rng.uniform(0, 2 * np.pi))
    if beat:
        twin = np.sin(2 * np.pi * (freq + beat) * t + rng.uniform(0, 2 * np.pi))
        tone = (tone + depth * twin) / (1 + depth)
    env = (1 - np.exp(-t / attack)) * np.exp(-t / decay)
    return amp * env * tone


def strike(t, amp, brightness, length):
    """Mallet transient: one-pole low-passed noise burst. Higher brightness = harder mallet."""
    n = min(len(t), int(SR * length * 10))
    x = rng.standard_normal(n)
    y = np.empty(n)
    acc = 0.0
    for i in range(n):
        acc += brightness * (x[i] - acc)
        y[i] = acc
    out = np.zeros(len(t))
    out[:n] = amp * y / (np.max(np.abs(y)) + 1e-9) * np.exp(-t[:n] / length)
    return out


def bowl(dur, f0, ratios, amps, decays, beats, depth, attack, strike_args):
    t = t_axis(dur)
    y = sum(partial(t, f0 * r, a, d, attack, b, depth)
            for r, a, d, b in zip(ratios, amps, decays, beats))
    return y + strike(t, *strike_args)


def tibetan():
    # Hand-hammered Himalayan bowl, padded mallet: low, warm, pronounced wobble
    return bowl(8.0, 207.0,
                ratios=(1.0, 2.76, 5.22, 8.43, 12.3),
                amps=(1.0, 0.55, 0.28, 0.12, 0.05),
                decays=(2.4, 1.6, 0.9, 0.55, 0.35),
                beats=(0.9, 2.1, 3.4, 4.0, 5.0),
                depth=0.5, attack=0.004,
                strike_args=(0.15, 0.25, 0.010))


def zen_bowl():
    # Japanese rin / temple bowl, harder striker: higher, clear, little wobble
    return bowl(8.0, 349.0,
                ratios=(1.0, 2.69, 4.95, 7.8),
                amps=(1.0, 0.7, 0.25, 0.1),
                decays=(2.8, 1.8, 0.8, 0.4),
                beats=(0.4, 1.2, 2.5, 3.0),
                depth=0.25, attack=0.001,
                strike_args=(0.25, 0.6, 0.006))


def crystal():
    # Quartz singing bowl, rubber mallet: nearly pure tone with faint harmonics
    return bowl(7.0, 523.25,
                ratios=(1.0, 2.0, 3.0),
                amps=(1.0, 0.08, 0.05),
                decays=(2.6, 1.0, 0.6),
                beats=(0.3, 0.0, 0.0),
                depth=0.15, attack=0.015,
                strike_args=(0.03, 0.1, 0.010))


def chime():
    # Three tuned tubes (E6, C6, G5) struck in quick succession; free-bar partial ratios
    dur = 5.0
    t = t_axis(dur)
    y = np.zeros(len(t))
    for freq, delay, amp in ((1318.5, 0.0, 1.0), (1046.5, 0.16, 0.8), (784.0, 0.36, 0.7)):
        start = int(delay * SR)
        tt = t[:len(t) - start]
        tube = sum(partial(tt, freq * r, a, d, attack=0.0008, beat=0.6 * r, depth=0.1)
                   for r, a, d in zip((1.0, 2.756, 5.404), (1.0, 0.35, 0.12), (1.3, 0.45, 0.18)))
        tube = tube + strike(tt, 0.25, 0.8, 0.003)
        y[start:] += amp * tube
    return y


def gong():
    # Large wind gong: low inharmonic boom, then high shimmer that swells in after the hit
    dur = 9.0
    t = t_axis(dur)
    y = sum(partial(t, f, a, d, attack=0.01, beat=b, depth=0.35)
            for f, a, d, b in ((82.0, 1.0, 2.6, 0.4), (131.0, 0.6, 2.2, 0.7), (197.0, 0.45, 1.9, 1.1)))
    lo, hi = np.log(250.0), np.log(4000.0)
    for _ in range(60):
        pos = rng.uniform()
        y += partial(t, np.exp(lo + pos * (hi - lo)),
                     amp=0.12 * (1 - 0.7 * pos) * rng.uniform(0.4, 1.0),
                     decay=2.2 - 1.3 * pos,
                     attack=0.15 + 0.9 * pos,
                     beat=rng.uniform(0.3, 2.5), depth=0.3)
    return y + strike(t, 0.5, 0.05, 0.04)


# filename -> (generator, loudness trim in dB)
BELLS = {
    "tibetan":  (tibetan, 0.0),
    "zen_bowl": (zen_bowl, 0.0),
    "crystal":  (crystal, -2.0),
    "chime":    (chime, -2.0),
    "gong":     (gong, 1.0),
}


def finish(y, trim_db):
    # Cosine² fade over the last 40% so the tail never cuts off abruptly
    n = len(y)
    s = int(n * 0.6)
    fade = np.ones(n)
    fade[s:] = np.cos(np.linspace(0, np.pi / 2, n - s)) ** 2
    y = y * fade
    rms = np.sqrt(np.mean(y[:int(1.5 * SR)] ** 2))
    y = y * TARGET_RMS * 10 ** (trim_db / 20) / rms
    peak = np.max(np.abs(y))
    if peak > PEAK:
        y = y * PEAK / peak
    return y


def write_caf(path, y):
    """Mono 16-bit little-endian linear PCM in a Core Audio Format container."""
    pcm = (np.clip(y, -1, 1) * 32767).astype("<i2").tobytes()
    lpcm_little_endian = 1 << 1
    with open(path, "wb") as f:
        f.write(struct.pack(">4sHH", b"caff", 1, 0))
        # desc: sample rate, format, flags, bytes/packet, frames/packet, channels, bits/channel
        f.write(struct.pack(">4sq", b"desc", 32))
        f.write(struct.pack(">d4sIIIII", float(SR), b"lpcm", lpcm_little_endian, 2, 1, 1, 16))
        # data: 4-byte edit count precedes the samples
        f.write(struct.pack(">4sqI", b"data", 4 + len(pcm), 0))
        f.write(pcm)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, (make, trim_db) in BELLS.items():
        y = finish(make(), trim_db)
        path = os.path.join(OUT_DIR, f"{name}.caf")
        write_caf(path, y)
        peak_db = 20 * np.log10(np.max(np.abs(y)))
        print(f"{name:9s} {len(y) / SR:4.1f}s  peak {peak_db:5.1f} dBFS  {os.path.getsize(path) // 1024} KB")


if __name__ == "__main__":
    main()
