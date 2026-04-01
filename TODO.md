# TODO.md - norad-war-simulator

## Current Status

- Phase 1: Foundation ✅ 100%
- Phase 2: Simulation ✅ 100%
- Phase 3: Scenarios ✅ 100%
- Phase 4: Campaign ✅ 100%
- Phase 5: Polish ✅ 100%
- Phase 6: Multiplayer ✅ 95% (scripts compile, needs testing)
- Phase 7: Steam ✅ 100%
- Phase 8: Launch 🔄 80% (build working, screenshots pending)

---

## Build Status (April 1, 2026)

### ✅ BUILD SUCCESSFUL

**Linux Binary Built:**
- `export/norad-war-simulator` - 68MB ELF 64-bit executable
- `export/norad-war-simulator.pck` - 3.8MB game data

**Export Templates Installed:**
- Godot 4.6.1 stable export templates
- Linux, Windows, macOS, Android, iOS, Web

**Scripts Fixed:**
All GDScript files compile without errors:
- lobby_menu.gd scene reference
- game_mode.gd enum → constants
- network_manager.gd enum → int
- defense_manager.gd TYPE_STATS access
- interceptor.gd Line3D → MeshInstance3D
- achievements_screen.gd TextureRect enum
- steam_manager.gd class_name removal
- main.gd preload → dynamic load

### Remaining for Release

1. **Screenshots** - Need to run game and capture 10 screenshots
2. **Trailer** - Create 60-second gameplay video
3. **Windows Build** - Run build.sh for Windows
4. **macOS Build** - Run build.sh for macOS
5. **GitHub Release** - Create v0.5.0-alpha release with binaries

---

## Build Commands

```bash
cd ~/stsgym-work/norad-war-simulator

# Linux (already done)
snap run godot-4 --headless --export-release "Linux/X11" export/norad-war-simulator

# Windows (needs build)
snap run godot-4 --headless --export-release "Windows Desktop" export/norad-war-simulator.exe

# macOS (needs build)
snap run godot-4 --headless --export-release "macOS" export/norad-war-simulator.dmg
```

---

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