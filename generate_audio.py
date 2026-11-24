import wave
import math
import struct
import random
import os

out_dir = r"D:\games\fpshooter\assets\audio"
os.makedirs(out_dir, exist_ok=True)
SAMPLE_RATE = 44100

def write_wav(filename, samples):
    path = os.path.join(out_dir, filename)
    with wave.open(path, 'w') as wav:
        wav.setnchannels(1) # mono
        wav.setsampwidth(2) # 16-bit
        wav.setframerate(SAMPLE_RATE)
        # Clamp samples to 16-bit range
        packed = bytearray()
        for s in samples:
            val = int(max(min(s, 1.0), -1.0) * 32767.0)
            packed.extend(struct.pack('<h', val))
        wav.writeframes(packed)
    print(f"Generated {filename}")

# 1. Pistol shot: punchy crack + short sub body + rapid decay
def gen_pistol_shot():
    duration = 0.28
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Envelope: sharp exponential decay
        env = math.exp(-t * 22.0)
        # Noise burst for crack
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 40.0)
        # Tone punch: dropping frequency
        freq = 320.0 * math.exp(-t * 30.0) + 60.0
        tone = math.sin(2.0 * math.pi * freq * t)
        sample = (0.7 * noise + 0.5 * tone) * env
        samples.append(sample)
    write_wav("pistol_shot.wav", samples)

# 2. Rifle shot: heavier transient + snappy tail + mechanical click
def gen_rifle_shot():
    duration = 0.22
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 26.0)
        # Heavier low transient
        freq = 240.0 * math.exp(-t * 25.0) + 70.0
        tone = math.sin(2.0 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 35.0)
        # Second click at 40ms
        click = 0.0
        if 0.035 < t < 0.055:
            click = (random.random() * 2.0 - 1.0) * 0.4
        sample = (0.8 * noise + 0.6 * tone + click) * env
        samples.append(sample)
    write_wav("rifle_shot.wav", samples)

# 3. Reload mechanical sound: click-clack magazine latch
def gen_reload():
    duration = 0.5
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        sample = 0.0
        # First latch eject (0.05s)
        if 0.04 < t < 0.09:
            sample += (random.random() * 2.0 - 1.0) * math.exp(-(t-0.04) * 80.0) * 0.7
        # Insert click (0.3s)
        if 0.28 < t < 0.35:
            sample += (random.random() * 2.0 - 1.0) * math.exp(-(t-0.28) * 90.0) * 0.8
            sample += math.sin(2.0 * math.pi * 880.0 * t) * math.exp(-(t-0.28) * 120.0) * 0.4
        # Lock slide (0.42s)
        if 0.40 < t < 0.48:
            sample += (random.random() * 2.0 - 1.0) * math.exp(-(t-0.40) * 70.0) * 0.9
        samples.append(sample)
    write_wav("reload.wav", samples)

# 4. Bullet impact / ricochet: metallic ting & thud
def gen_impact():
    duration = 0.2
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 50.0) * 0.6
        # Metallic ping frequency glide
        freq = 1400.0 * math.exp(-t * 15.0) + 400.0
        ping = math.sin(2.0 * math.pi * freq * t) * 0.4
        sample = (noise + ping) * env
        samples.append(sample)
    write_wav("impact.wav", samples)

# 5. Explosion / drone destroyed: deep low boom + debris crackle
def gen_explosion():
    duration = 0.7
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 6.5)
        freq = 90.0 * math.exp(-t * 8.0) + 35.0
        sub_boom = math.sin(2.0 * math.pi * freq * t) * 0.8
        dist_noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 10.0) * 0.7
        # lowpass simulation roughly
        sample = (sub_boom + dist_noise) * env
        samples.append(sample)
    write_wav("explosion.wav", samples)

# 6. Switch weapon whoosh / click
def gen_switch():
    duration = 0.15
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 30.0)
        click = (random.random() * 2.0 - 1.0) * 0.5 * env
        tone = math.sin(2.0 * math.pi * 600.0 * t) * 0.3 * env
        samples.append(click + tone)
    write_wav("switch.wav", samples)

gen_pistol_shot()
gen_rifle_shot()
gen_reload()
gen_impact()
gen_explosion()
gen_switch()
print("All audio generated successfully!")
