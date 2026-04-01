# TODO.md - norad-war-simulator

## Current Status

- Phase 1: Foundation ✅ 100%
- Phase 2: Simulation ✅ 100%
- Phase 3: Scenarios ✅ 100%
- Phase 4: Campaign ✅ 100%
- Phase 5: Polish ✅ 100%
- Phase 6: Multiplayer ✅ 95% (scripts compile, needs testing)
- Phase 7: Steam ✅ 100%
- Phase 8: Launch ✅ 90% (RELEASED on GitHub!)

---

## 🎉 RELEASE PUBLISHED

**GitHub Release:** https://github.com/wezzels/norad-war-simulator/releases/tag/v0.5.0-alpha

| Platform | File | Size | Status |
|----------|------|------|--------|
| **Linux x86_64** | norad-war-simulator-linux-x86_64 | 68MB | ✅ Uploaded |
| **Windows x86_64** | norad-war-simulator-windows-x86_64.exe | 100MB | ✅ Uploaded |
| **macOS** | — | — | ⏳ Needs template |

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

---

## Remaining for Full Launch

### High Priority
1. **Screenshots** - Need display to run game visually
2. **Trailer** - 60-second gameplay video
3. **macOS Build** - Extract templates and build

### Medium Priority
4. **Steam Submission** - When assets ready
5. **Testing** - Multiplayer needs network testing
6. **Marketing** - Press kit, social media

### Low Priority
7. **Web Build** - Not configured
8. **Mobile Builds** - Android/iOS (not prioritized)

---

*Last updated: April 1, 2026 18:10 UTC*

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