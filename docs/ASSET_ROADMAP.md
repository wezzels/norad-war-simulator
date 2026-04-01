# NORAD War Simulator - Asset Creation Roadmap

## Overview

This document lists all assets needed for the game, organized by development phase and priority.

---

## Phase 1: Foundation Assets (COMPLETE ✅)

### Core Visuals

| Asset | Status | File | Description |
|-------|--------|------|-------------|
| Globe Earth Texture | ✅ Done | `assets/textures/earth/` | NASA Blue Marble |
| Globe Normal Map | ✅ Done | `assets/textures/earth/` | Elevation data |
| Globe Clouds | ✅ Done | `assets/textures/earth/` | Cloud layer |
| Starfield Background | ✅ Done | `assets/textures/background/` | Space background |
| UI Frame | ✅ Done | `assets/textures/ui/` | Window frames |
| Button Normal | ✅ Done | `assets/textures/ui/` | Button states |
| Button Pressed | ✅ Done | `assets/textures/ui/` | Button pressed |
| Button Hover | ✅ Done | `assets/textures/ui/` | Button hover |

### Game Objects

| Asset | Status | File | Description |
|-------|--------|------|-------------|
| Missile Model | ✅ Done | `scenes/missile.tscn` | Missile 3D model |
| Interceptor Model | ✅ Done | `scenes/interceptor.tscn` | Interceptor 3D model |
| Explosion Effect | ✅ Done | `scenes/explosion.tscn` | Nuclear explosion |
| Contrail Effect | ✅ Done | `scripts/simulation/contrail.gd` | Missile trail |

### Core Audio

| Asset | Status | File | Description |
|-------|--------|------|-------------|
| Click Sound | ⚠️ Placeholder | `audio/sfx/click.wav` | UI click |
| Launch Sound | ⚠️ Placeholder | `audio/sfx/launch.wav` | Missile launch |
| Explosion Sound | ⚠️ Placeholder | `audio/sfx/explosion.wav` | Detonation |
| Intercept Sound | ⚠️ Placeholder | `audio/sfx/intercept.wav` | Successful intercept |

### Data Files

| Asset | Status | File | Description |
|-------|--------|------|-------------|
| Cities Database | ✅ Done | `data/cities.json` | 25 US cities |
| Launch Sites | ✅ Done | `data/launch_sites.json` | Launch locations |
| Satellites | ✅ Done | `data/satellites.json` | DSP, SBIRS, GPS |
| Scenarios | ✅ Done | `data/scenarios/*.json` | 6 scenarios |

---

## Phase 2: Simulation Assets (COMPLETE ✅)

### Visual Enhancements

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Missile Trail Particle | ⚠️ Needed | Medium | Enhanced trail effect |
| Interceptor Trail | ⚠️ Needed | Medium | Interceptor exhaust |
| Nuclear Explosion Sprite | ⚠️ Needed | High | Mushroom cloud sprite |
| EMP Effect | ⚠️ Needed | Low | Electromagnetic pulse |
| Shockwave Effect | ⚠️ Needed | Medium | Explosion shockwave |
| Fireball Sprite | ⚠️ Needed | High | Initial explosion fire |

### Missile Variants

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| ICBM Model | ✅ Done | - | Standard ICBM |
| IRBM Model | ⚠️ Needed | Medium | Medium-range variant |
| SRBM Model | ⚠️ Needed | Medium | Short-range variant |
| MIRV Warhead | ⚠️ Needed | Low | Multiple warhead |
| Hypersonic Model | ⚠️ Needed | Low | Hypersonic missile |

### Interceptor Variants

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| GBI Model | ✅ Done | - | Ground-Based Interceptor |
| THAAD Model | ⚠️ Needed | High | Terminal interceptor |
| Patriot Model | ⚠️ Needed | High | Point defense |
| Aegis Model | ⚠️ Needed | Medium | Ship-based |
| Iron Dome Model | ⚠️ Needed | Low | Israeli system |

### Satellite Visuals

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| DSP Satellite | ⚠️ Needed | Medium | Early warning sat |
| SBIRS Satellite | ⚠️ Needed | Medium | Infrared sat |
| GPS Satellite | ⚠️ Needed | Low | Navigation sat |
| Satellite Orbit Line | ⚠️ Needed | Medium | Orbital path visual |

---

## Phase 3: Scenario Assets (COMPLETE ✅)

### Scenario Data

| Asset | Status | File | Description |
|-------|--------|------|-------------|
| Tutorial Scenario | ✅ Done | `data/scenarios/tutorial.json` | Single missile |
| Cold War Scenario | ✅ Done | `data/scenarios/cold_war.json` | 10 missiles |
| Regional Conflict | ✅ Done | `data/scenarios/regional.json` | 25 missiles |
| Major Exchange | ✅ Done | `data/scenarios/major.json` | 50 missiles |
| Apocalypse | ✅ Done | `data/scenarios/apocalypse.json` | 100 missiles |
| Custom Scenario Template | ✅ Done | `data/scenarios/template.json` | User scenarios |

### Map Overlays

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| DEFCON Regions | ⚠️ Needed | High | Defense regions overlay |
| Threat Trajectory Lines | ✅ Done | - | Missile flight paths |
| Interceptor Range Circles | ⚠️ Needed | Medium | Coverage visualization |
| Satellite Coverage | ⚠️ Needed | Medium | Detection zones |
| City Markers | ⚠️ Needed | High | Population icons |

### Environment Textures

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Night Earth Texture | ⚠️ Needed | Medium | City lights |
| Ocean Texture | ⚠️ Needed | Low | Water surface |
| Atmosphere Shader | ⚠️ Needed | Medium | Atmospheric glow |
| Sun Flare | ⚠️ Needed | Low | Sun visual |
| Moon Texture | ⚠️ Needed | Low | Moon detail |

---

## Phase 4: Campaign Assets (COMPLETE ✅)

### Campaign Story

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Campaign Script | ✅ Done | - | 8 missions |
| Mission Briefings | ✅ Done | `data/campaign/briefings/` | Text briefings |
| Character Dialogs | ⚠️ Needed | High | Voice lines |
| Story Background | ✅ Done | - | Setting lore |
| Faction Descriptions | ⚠️ Needed | Medium | Enemy nations |

### Campaign Visuals

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Mission Briefing Images | ⚠️ Needed | High | Intel photos |
| Character Portraits | ⚠️ Needed | Medium | Commander faces |
| Map Story Overlays | ⚠️ Needed | Medium | Story markers |
| Tech Tree Icons | ⚠️ Needed | High | Upgrade icons |
| Achievement Icons | ⚠️ Needed | High | Badge images |

### Campaign Audio

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Mission Briefing VO | ⚠️ Needed | High | Voice actor lines |
| Commander Voice | ⚠️ Needed | Medium | In-game dialog |
| Alert Sounds | ⚠️ Needed | High | DEFCON alerts |
| Success Jingles | ⚠️ Needed | Medium | Victory sounds |
| Failure Sounds | ⚠️ Needed | Medium | Defeat sounds |

### Tech Tree Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Tech Tree Layout | ✅ Done | - | Upgrade paths |
| Tech Icons (10) | ⚠️ Needed | High | 10 tech icons |
| Tech Descriptions | ✅ Done | - | Text descriptions |
| Tech Prerequisites | ✅ Done | - | Dependency graph |

---

## Phase 5: Polish Assets (PARTIAL ⚠️)

### UI/UX Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Main Menu Background | ⚠️ Needed | HIGH | Title screen art |
| Menu Theme Music | ⚠️ Needed | HIGH | Background music |
| HUD Frame | ⚠️ Needed | High | Game HUD overlay |
| DEFCON Indicator | ⚠️ Needed | High | DEFCON level display |
| Threat Counter | ⚠️ Needed | High | Active threat count |
| Interceptor Counters | ⚠️ Needed | High | GBI/THAAD/Patriot |
| Timer Display | ⚠️ Needed | Medium | Countdown |
| Mini-map Frame | ⚠️ Needed | Medium | Globe mini-view |
| Settings Panel | ⚠️ Needed | Medium | Options screen |
| Credits Screen | ⚠️ Needed | Low | Developer credits |

### Menu Screens

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Main Menu BG | ⚠️ Needed | HIGH | 1920x1080 background |
| Campaign Menu BG | ⚠️ Needed | High | Mission select screen |
| Scenario Select BG | ⚠️ Needed | High | Scenario cards |
| Settings Screen BG | ⚠️ Needed | Medium | Options background |
| Pause Menu | ⚠️ Needed | High | In-game pause |
| Game Over Screen | ⚠️ Needed | High | Victory/defeat |

### Font Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Main Title Font | ⚠️ Needed | HIGH | Military/stencil font |
| HUD Font | ⚠️ Needed | HIGH | Readable mono font |
| Body Text Font | ⚠️ Needed | Medium | Narrative text |
| Technical Font | ⚠️ Needed | Medium | Data displays |

### Audio Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Menu Music | ⚠️ Needed | HIGH | Title screen loop (3 min) |
| Game Music | ⚠️ Needed | HIGH | Background music (10 min) |
| Combat Music | ⚠️ Needed | High | Tension music (5 min) |
| Victory Music | ⚠️ Needed | Medium | Success jingle |
| Defeat Music | ⚠️ Needed | Medium | Failure jingle |

### Sound Effects

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Missile Launch | ⚠️ Placeholder | HIGH | Rocket launch |
| Interceptor Launch | ⚠️ Placeholder | HIGH | Defense launch |
| Explosion Large | ⚠️ Placeholder | HIGH | Nuclear |
| Explosion Small | ⚠️ Placeholder | High | Conventional |
| Alert Siren | ⚠️ Needed | HIGH | DEFCON alert |
| Button Click | ⚠️ Placeholder | High | UI click |
| Button Hover | ⚠️ Needed | Medium | UI hover |
| Message Beep | ⚠️ Needed | Medium | Notification |
| Radar Sweep | ⚠️ Needed | Medium | Detection sound |
| Intercept Success | ⚠️ Placeholder | High | Kill confirmation |
| Intercept Fail | ⚠️ Needed | High | Miss sound |
| City Destroyed | ⚠️ Needed | High | Impact sound |

---

## Phase 6: Multiplayer Assets (PLANNED)

### Multiplayer UI

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Lobby Background | ⚠️ Needed | High | Lobby screen |
| Player Card Template | ⚠️ Needed | High | Player info display |
| Team Indicator | ⚠️ Needed | High | Team Alpha/Bravo |
| Connection Status | ⚠️ Needed | High | Network indicator |
| Chat Bubble | ⚠️ Needed | Medium | In-game chat |
| Score Display | ⚠️ Needed | High | Multiplayer scores |
| Co-op HUD | ⚠️ Needed | High | Shared resources |

### Multiplayer Audio

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Player Join Sound | ⚠️ Needed | Medium | Connection sound |
| Player Leave Sound | ⚠️ Needed | Medium | Disconnection |
| Team Chat Sound | ⚠️ Needed | Medium | Message received |
| Victory Team Sound | ⚠️ Needed | High | Team victory |
| Defeat Team Sound | ⚠️ Needed | High | Team defeat |

---

## Phase 7: Steam Assets (PARTIAL ⚠️)

### Store Page Assets

| Asset | Status | Size | Priority | Description |
|-------|--------|------|----------|-------------|
| **Header Capsule** | ✅ Done | 460x215 | HIGH | Main store image |
| **Main Capsule** | ✅ Done | 616x353 | HIGH | Library image |
| **Small Capsule** | ✅ Done | 231x87 | HIGH | Small library |
| **Page Background** | ⚠️ Needed | 1920x1080 | HIGH | Store page BG |
| **Hero Banner** | ⚠️ Needed | 1920x620 | High | Featured banner |

### Logo Assets

| Asset | Status | Size | Priority | Description |
|-------|--------|------|----------|-------------|
| **Main Logo** | ✅ Done | SVG | HIGH | Game logo |
| **Logo 512x512** | ✅ Done | 512x512 | HIGH | Standard logo |
| **Logo 256x256** | ✅ Done | 256x256 | HIGH | Medium logo |
| **Logo 128x128** | ✅ Done | 128x128 | HIGH | Small logo |
| **Icon 64x64** | ⚠️ Needed | 64x64 | Medium | Taskbar icon |
| **Icon 32x32** | ⚠️ Needed | 32x32 | Medium | Small icon |
| **Icon 16x16** | ⚠️ Needed | 16x16 | Medium | Favicon |

### Screenshot Assets (NEEDED ⚠️)

| # | Status | Size | Scene | Description |
|---|--------|------|-------|-------------|
| 1 | ⚠️ Needed | 1920x1080 | Main Menu | Title screen |
| 2 | ⚠️ Needed | 1920x1080 | Globe View | Earth from space |
| 3 | ⚠️ Needed | 1920x1080 | Defense | Interceptors launching |
| 4 | ⚠️ Needed | 1920x1080 | Attack | Missile trajectories |
| 5 | ⚠️ Needed | 1920x1080 | Explosion | Nuclear detonation |
| 6 | ⚠️ Needed | 1920x1080 | HUD | Game interface |
| 7 | ⚠️ Needed | 1920x1080 | Campaign | Mission briefing |
| 8 | ⚠️ Needed | 1920x1080 | Tech Tree | Upgrades screen |
| 9 | ⚠️ Needed | 1920x1080 | Multiplayer | Co-op lobby |
| 10 | ⚠️ Needed | 1920x1080 | Victory | Win screen |

### Trailer Assets (NEEDED ⚠️)

| Asset | Status | Duration | Priority | Description |
|-------|--------|----------|----------|-------------|
| **Main Trailer** | ⚠️ Needed | 60 sec | HIGH | Gameplay showcase |
| **Teaser Trailer** | ⚠️ Needed | 30 sec | High | Short promo |
| **Launch Trailer** | ⚠️ Needed | 90 sec | HIGH | Full release |

### Steam Integration Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Achievement Icons (18) | ⚠️ Needed | High | 64x64 badge images |
| Achievement Descriptions | ✅ Done | - | Text descriptions |
| Leaderboard Names | ✅ Done | - | Leaderboard titles |
| Cloud Save Schema | ✅ Done | - | Save format |

---

## Phase 8: Launch Assets (IN PROGRESS)

### Documentation

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| README.md | ✅ Done | HIGH | Project overview |
| BUILD.md | ✅ Done | HIGH | Build instructions |
| CONTRIBUTING.md | ✅ Done | High | Contribution guide |
| ARCHITECTURE.md | ✅ Done | Medium | System design |
| MEDIA_ASSETS.md | ✅ Done | Medium | Asset list |
| STEAM_STORE_PAGE.md | ✅ Done | HIGH | Store description |
| CHANGELOG.md | ✅ Done | High | Version history |
| LICENSE | ✅ Done | HIGH | MIT License |

### Legal Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| EULA | ⚠️ Needed | HIGH | End User License |
| Privacy Policy | ⚠️ Needed | High | Data handling |
| Third Party Licenses | ⚠️ Needed | Medium | Asset attributions |
| Font Licenses | ⚠️ Needed | Medium | Font usage rights |

### Press Kit Assets

| Asset | Status | Priority | Description |
|-------|--------|----------|-------------|
| Press Release | ⚠️ Needed | HIGH | Launch announcement |
| Fact Sheet | ⚠️ Needed | High | Game facts |
| Developer Bio | ⚠️ Needed | Medium | Team info |
| Screenshots (10) | ⚠️ Needed | HIGH | Press screenshots |
| Logo Pack | ⚠️ Needed | HIGH | All logo sizes |
| Trailer Link | ⚠️ Needed | HIGH | Video URL |
| Press Contact | ⚠️ Needed | Medium | PR contact |

---

## Asset Creation Priority Order

### Critical Path (Must Have for Release)

1. **Menu Background** - Main menu needs visual
2. **HUD Elements** - Game needs interface
3. **10 Screenshots** - Steam requirement
4. **Main Trailer (60s)** - Steam requirement
5. **Sound Effects (Launch, Intercept, Alert, Explosion)** - Core gameplay
6. **Music (Menu + Game)** - Atmosphere
7. **Fonts** - Readable UI

### High Priority (Should Have)

8. **Achievement Icons** - Steam integration
9. **Tech Tree Icons** - Campaign mode
10. **Missile/Interceptor Variants** - Visual variety
11. **City Markers** - Map clarity
12. **Satellite Visuals** - Detection visualization

### Medium Priority (Nice to Have)

13. **Campaign Briefing Images** - Story depth
14. **Character Portraits** - Narrative
15. **Night Earth Texture** - Visual polish
16. **Atmosphere Shader** - Visual quality
17. **Multiplayer Lobby BG** - Co-op mode

### Low Priority (Future Enhancement)

18. **Moon Texture** - Visual detail
19. **EMP Effect** - Special weapon
20. **Iron Dome Model** - Additional content

---

## Asset Creation Workflow

### Visual Assets

```
1. Concept Art → 2. Draft → 3. Refine → 4. Final → 5. Export
   (Sketch)     (Outline)   (Detail)   (Polish)   (PNG/SVG)
```

### Audio Assets

```
1. Recording → 2. Editing → 3. Effects → 4. Mix → 5. Export
   (Raw)        (Cut)       (Process)   (Level)    (OGG/WAV)
```

### Data Assets

```
1. Research → 2. Draft JSON → 3. Validate → 4. Test → 5. Commit
   (Data)      (Structure)   (Schema)     (Game)    (Git)
```

---

## Asset File Formats

| Type | Format | Notes |
|------|--------|-------|
| Textures | PNG, SVG | PNG for raster, SVG for scalable |
| Models | GLTF, GLB | Godot native format |
| Audio | OGG, WAV | OGG for music, WAV for SFX |
| Fonts | TTF, OTF | TrueType/OpenType |
| Data | JSON | Structured data |
| Video | MP4, WEBM | Trailers |

---

## Asset Checklist Summary

| Category | Total | Done | Needed | Progress |
|----------|-------|------|--------|----------|
| Core Visuals | 9 | 9 | 0 | 100% |
| Game Objects | 4 | 4 | 0 | 100% |
| Core Audio | 4 | 0 | 4 | 0% |
| Data Files | 4 | 4 | 0 | 100% |
| Visual Enhancements | 18 | 0 | 18 | 0% |
| Missile Variants | 5 | 1 | 4 | 20% |
| Interceptor Variants | 5 | 1 | 4 | 20% |
| Satellite Visuals | 4 | 0 | 4 | 0% |
| Scenario Data | 6 | 6 | 0 | 100% |
| Map Overlays | 5 | 1 | 4 | 20% |
| Environment | 5 | 0 | 5 | 0% |
| Campaign Story | 5 | 3 | 2 | 60% |
| Campaign Visuals | 5 | 0 | 5 | 0% |
| Campaign Audio | 5 | 0 | 5 | 0% |
| Tech Tree | 4 | 2 | 2 | 50% |
| UI/UX | 20 | 0 | 20 | 0% |
| Menu Screens | 6 | 0 | 6 | 0% |
| Fonts | 4 | 0 | 4 | 0% |
| Music | 5 | 0 | 5 | 0% |
| Sound Effects | 15 | 0 | 15 | 0% |
| Multiplayer UI | 7 | 0 | 7 | 0% |
| Multiplayer Audio | 5 | 0 | 5 | 0% |
| Store Page | 5 | 3 | 2 | 60% |
| Logos | 7 | 4 | 3 | 57% |
| Screenshots | 10 | 0 | 10 | 0% |
| Trailers | 3 | 0 | 3 | 0% |
| Steam Integration | 4 | 2 | 2 | 50% |
| Documentation | 8 | 8 | 0 | 100% |
| Legal | 4 | 0 | 4 | 0% |
| Press Kit | 7 | 0 | 7 | 0% |
| **TOTAL** | **174** | **43** | **131** | **25%** |

---

## Next Steps

### Immediate (Before Beta)

1. ⚠️ **Menu Background** - Create main menu art
2. ⚠️ **HUD Elements** - Design game interface
3. ⚠️ **Sound Effects** - Record/obtain core SFX
4. ⚠️ **Music** - Create or license menu/game music
5. ⚠️ **Fonts** - Select readable fonts

### Before Steam Release

6. ⚠️ **10 Screenshots** - Capture gameplay
7. ⚠️ **60s Trailer** - Create promotional video
8. ⚠️ **Achievement Icons** - Design 18 badges
9. ⚠️ **Press Kit** - Prepare PR materials
10. ⚠️ **Legal Docs** - EULA, Privacy Policy

### Post-Launch

11. Additional missile/interceptor variants
12. Enhanced visual effects
13. More scenarios
14. Multiplayer polish

---

*Created: April 1, 2026*
*Last Updated: April 1, 2026*
*Author: Lucky (OpenClaw Agent)*