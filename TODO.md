# TODO.md - norad-war-simulator

## Current Status

- Phase 1: Foundation ✅ 100%
- Phase 2: Simulation ✅ 100%
- Phase 3: Scenarios ✅ 100%
- Phase 4: Campaign ✅ 100%
- Phase 5: Polish ✅ 100%
- Phase 6: Multiplayer ✅ 95% (scripts compile, needs testing)
- Phase 7: Steam ✅ 100%
- Phase 8: Launch 🔄 50% (scripts fixed, export needs templates)

---

## Build Status (April 1, 2026)

### Scripts ✅ COMPILE
All GDScript files now compile without errors:
- Fixed lobby_menu.gd scene reference
- Fixed game_mode.gd enum → constants
- Fixed network_manager.gd enum → int
- Fixed defense_manager.gd TYPE_STATS access
- Fixed interceptor.gd Line3D → MeshInstance3D
- Fixed achievements_screen.gd TextureRect enum
- Fixed steam_manager.gd class_name removal
- Fixed main.gd preload → dynamic load

### Audio Issues ⚠️ NEEDS FIX
WAV files need conversion to PCM format. Run:
```bash
cd ~/stsgym-work/norad-war-simulator
for f in audio/sfx/*.wav; do
  name=$(basename "$f")
  sox "$f" -t wav -e signed-integer -b 16 "assets/audio/$name"
done
```

### Export Templates ⚠️ NOT INSTALLED
Godot snap doesn't include export templates. Need:
```bash
# Download templates from godotengine.org
# Or use official flatpak version
flatpak install flathub org.godotengine.Godot
```

---

## Phase 8: Launch Status

### Build Scripts ✅ DONE
- [x] build.sh for cross-platform builds
- [x] Linux export preset
- [x] Windows export preset
- [x] macOS export preset
- [x] Source package script
- [x] Checksums generation
- [x] Release notes template

### Documentation ✅ DONE
- [x] README.md with project overview
- [x] LICENSE (MIT)
- [x] docs/BUILD.md with build instructions
- [x] docs/CONTRIBUTING.md for contributors
- [x] docs/ARCHITECTURE.md for developers

### GitHub ✅ DONE
- [x] Create GitHub repository
- [x] Push to GitHub (wezzels/norad-war-simulator)
- [x] Project description

### Media Assets ✅ DONE (Binaries pending)
- [x] Logo SVG created (assets/logo.svg)
- [x] Header capsule PNG (assets/store/header_capsule.png)
- [x] Main capsule PNG (assets/store/main_capsule.png)
- [x] Small capsule PNG (assets/store/small_capsule.png)
- [x] Logo PNGs (512x512, 256x256, 128x128)
- [x] Hero banner PNG (1920x620)
- [ ] 10 in-game screenshots (requires running Godot)
- [ ] 60-second trailer video

### Release ⚠️ PENDING
- [x] Create v0.5.0-alpha release draft
- [x] Release notes with features
- [ ] Build binaries (Linux/Windows/macOS)
- [ ] Upload binaries to GitHub release

---

## Next Steps

1. **Fix Audio** - Convert WAV files to PCM format
2. **Install Export Templates** - Get Godot templates for building
3. **Build Binaries** - Export for all platforms
4. **Take Screenshots** - Run game and capture 10 screenshots
5. **Create Trailer** - 60-second gameplay video

---

*Last updated: April 1, 2026*