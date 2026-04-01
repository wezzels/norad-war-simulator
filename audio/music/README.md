# Music Tracks

Procedurally generated ambient music using sox. These are placeholder tracks for development.

## Generated Files

- `menu.ogg` - Menu theme (calm ambient, harmonic sine waves)
- `game_ambient.ogg` - In-game background (brown noise, tension)
- `crisis.ogg` - High DEFCON tension (low sawtooth drone)

## Regenerating Music

```bash
cd audio/music

# Menu theme - calm harmonic
sox -n menu.ogg synth 30.0 sine 220 : synth 30.0 sine 330 : synth 30.0 sine 440 fade 2.0 30.0 2.0 vol 0.2

# Game ambient - tension
sox -n game_ambient.ogg synth 30.0 brownnoise fade 2.0 30.0 2.0 vol 0.1

# Crisis - high tension
sox -n crisis.ogg synth 30.0 saw 110 : synth 30.0 saw 165 fade 2.0 30.0 2.0 vol 0.15
```

## Improving Music

For production, consider replacing with:
- Royalty-free ambient music from OpenGameArt.org
- Custom composed tracks
- Adaptive music systems that respond to game state

## Format

- OGG Vorbis for music (loopable, good compression)
- 30-second loops for development
- Consider longer tracks (2-3 minutes) for production