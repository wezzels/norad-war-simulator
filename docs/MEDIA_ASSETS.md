# Media Assets Required

## Steam Store Requirements

### Capsule Images
| Type | Size | Usage |
|------|------|-------|
| Header | 460x215 px | Store header |
| Main Capsule | 616x353 px | Store capsule |
| Small Capsule | 200x112 px | Library capsule |
| Hero | 1920x620 px | Store hero banner |
| Page Background | 1920x1080 px | Store background |

### Screenshots (10 required, 5 minimum)
1. Main menu with globe
2. Missile tracking view
3. Interceptor launch sequence
4. Campaign tech tree
5. Scenario editor
6. Multiplayer lobby
7. Achievement screen
8. DEFCON alert view
9. City impact/explosion
10. Satellite detection network

### Trailer
- Duration: 60 seconds
- Resolution: 1920x1080 (1080p)
- Format: MP4 (H.264)
- See: docs/STEAM_STORE_PAGE.md for script

### Additional
- Logo (transparent PNG, 512x512)
- Banner (512x256)
- Icon (256x256, matches project icon)

## Asset Sources

### Free Assets (CC0/Public Domain)
- NASA Blue Marble: https://visibleearth.nasa.gov/collection/1484/blue-marble
- NASA Earth textures: https://eoimages.gsfc.nasa.gov/
- OpenGameArt: https://opengameart.org
- Freesound: https://freesound.org

### Created Assets
- Icon: Use project icon.svg
- Logo: Create from game title
- Screenshots: Run game in Godot

## Screenshot Guidelines

1. **Resolution**: 1920x1080 minimum
2. **Format**: PNG preferred
3. **Content**: Show actual gameplay
4. **Text**: Minimal UI text visible
5. **Action**: Show missiles, interceptors, explosions
6. **Variety**: Different scenarios, game modes

## Creating Screenshots

```bash
# Run game in Godot
godot project.godot

# Press F12 or screenshot button in-game
# Or use system screenshot tool

# On Linux with Flameshot:
flameshot gui

# On Linux with GNOME:
gnome-screenshot -a
```

## Current Status

- [ ] Header capsule (460x215)
- [ ] Main capsule (616x353)
- [ ] Small capsule (200x112)
- [ ] Hero banner (1920x620)
- [ ] Page background (1920x1080)
- [ ] Logo (512x512)
- [ ] Banner (512x256)
- [ ] 10 screenshots
- [ ] Trailer video