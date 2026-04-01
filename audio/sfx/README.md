# Sound Effects

Procedurally generated audio using sox. These are placeholder sounds for development.

## Generated Files

### UI Sounds
- `click.wav` - Button click (short, crisp square wave)
- `hover.wav` - Button hover (subtle sine blip)

### Game Sounds
- `alert_warning.wav` - Alert klaxon (sawtooth, medium urgency)
- `alert_critical.wav` - Critical alert (higher frequency)
- `launch.wav` - Missile launch (low rumble)
- `intercept.wav` - Interception (noise burst)
- `detonation.wav` - Nuclear detonation (massive boom)
- `defcon_change.wav` - DEFCON level change (alert tones)

## Regenerating Sounds

If you need to regenerate these sounds:

```bash
cd audio/sfx

# Click
sox -n click.wav synth 0.08 square 800 fade 0.01 0.08 0.02 vol 0.3

# Hover
sox -n hover.wav synth 0.04 sine 1200 fade 0.01 0.04 0.02 vol 0.15

# Alert warning
sox -n alert_warning.wav synth 0.3 saw 440 fade 0.01 0.3 0.05 : synth 0.3 saw 330 fade 0.01 0.3 0.05 : synth 0.3 saw 440 fade 0.01 0.3 0.05 : synth 0.3 saw 330 fade 0.01 0.3 0.05 vol 0.4

# Alert critical
sox -n alert_critical.wav synth 0.2 saw 880 fade 0.01 0.2 0.03 : synth 0.2 saw 660 fade 0.01 0.2 0.03 : synth 0.2 saw 880 fade 0.01 0.2 0.03 : synth 0.2 saw 660 fade 0.01 0.2 0.03 vol 0.5

# Launch
sox -n launch.wav synth 0.5 saw 80 : synth 0.5 saw 60 : synth 0.5 saw 100 fade 0.1 0.5 0.2 vol 0.5

# Intercept
sox -n intercept.wav synth 0.3 noise fade 0.01 0.3 0.15 : synth 0.2 square 200 fade 0.01 0.2 0.1 vol 0.4

# Detonation
sox -n detonation.wav synth 0.8 noise fade 0.01 0.3 0.5 : synth 0.6 saw 40 fade 0.01 0.2 0.4 : synth 0.4 square 30 fade 0.01 0.1 0.3 vol 0.6

# DEFCON change
sox -n defcon_change.wav synth 0.15 sine 1000 fade 0.01 0.15 0.05 : synth 0.15 sine 800 fade 0.01 0.15 0.05 : synth 0.3 sine 1200 fade 0.01 0.3 0.1 vol 0.35
```

## Improving Sounds

For production, consider replacing with higher quality sounds from:
- [Freesound.org](https://freesound.org) - CC0 sounds
- [OpenGameArt.org](https://opengameart.org) - Game audio assets
- [NASA Audio](https://www.nasa.gov/connect/sounds/) - Space-related sounds

## Format

- WAV for short sounds (UI, effects)
- OGG for music (loopable)
- Sample rate: 44100 Hz
- Bit depth: 16-bit
- Mono for 3D sounds, Stereo for music