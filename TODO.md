# TODO.md - norad-war-simulator

## Current Status

- Phase 1: Foundation ✅ 100%
- Phase 2: Simulation ✅ 100%
- Phase 3: Scenarios ✅ 100%
- Phase 4: Campaign ✅ 100%
- Phase 5: Polish ✅ 100%
- Phase 6: Multiplayer ✅ 95% (scripts compile, needs testing)
- Phase 7: Steam ✅ 100%
- Phase 8: Launch 🔄 85% (binaries built, screenshots pending)

---

## Build Status (April 1, 2026)

### ✅ BUILDS SUCCESSFUL

**Linux Binary:**
- `export/norad-war-simulator` - 68MB ELF 64-bit executable ✅
- Game runs successfully!

**Windows Binary:**
- `export/norad-war-simulator.exe` - 100MB PE32+ executable ✅

**Game Data:**
- `export/norad-war-simulator.pck` - 3.8MB

**macOS:**
- ⏳ Needs template extraction from `macos.zip`
- Standard templates don't include x86_64 binary

### Export Templates Installed

Templates at: `~/snap/godot-4/21/.local/share/godot/export_templates/4.6.1.stable.mono/`

Available platforms:
- Linux (x86_64, arm64, x86_32) ✅
- Windows (x86_64, x86_32, arm64) ✅
- macOS (universal zip) - needs extraction
- Android (apk) ✅
- iOS (zip) ✅
- Web (wasm) ✅

---

## Remaining for Release

### High Priority
1. **Screenshots** - Need display to run game visually
2. **Trailer** - 60-second gameplay video
3. **GitHub Release** - Create v0.5.0-alpha with binaries

### Medium Priority
4. **macOS Build** - Extract templates and build
5. **Steam Submission** - When assets ready
6. **Testing** - Multiplayer needs network testing

### Low Priority
7. **Web Build** - Not configured
8. **Mobile Builds** - Android/iOS (not prioritized)

---

## Build Commands

```bash
cd ~/stsgym-work/norad-war-simulator

# Linux (already done)
snap run godot-4 --headless --export-release "Linux/X11" export/norad-war-simulator

# Windows (already done)
snap run godot-4 --headless --export-release "Windows Desktop" export/norad-war-simulator.exe

# macOS (needs template extraction first)
unzip ~/snap/godot-4/common/.local/share/godot/export_templates/4.6.1.stable.mono/macos.zip -d /tmp/macos
snap run godot-4 --headless --export-release "macOS" export/norad-war-simulator.zip
```

---

*Last updated: April 1, 2026 18:15 UTC*

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