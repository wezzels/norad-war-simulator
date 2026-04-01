# NORAD War Simulator - Product Roadmap

**Repository**: `norad-war-simulator`
**Target Platforms**: Linux, Windows, macOS, Steam
**License**: MIT (open source) or Proprietary (TBD)
**Created**: 2026-03-31

---

## Executive Summary

Transform the existing `norad-sim` Flask web application into a fully-featured, cross-platform desktop game with:
- Real-time 3D global battlefield visualization
- Scenario editor and playback system
- Multiplayer support (co-op and adversarial)
- Steam integration (achievements, workshop, multiplayer)

---

## Current State Analysis

### Existing Assets (norad-sim)

| Component | Status | Technology |
|-----------|--------|------------|
| Flask Backend | ✅ Working | Python/Flask-SocketIO |
| Web UI | ✅ Working | HTML/CSS/JS, Leaflet.js |
| Missile Physics | ✅ Basic | Simplified trajectory |
| Satellite Telemetry | ✅ Working | Simulated DSP/SBIRS/GPS |
| Intercept System | ✅ Basic | Probability-based |
| Authentication | ✅ Working | SSO via auth.stsgym.com |
| WebSocket | ✅ Working | Socket.IO real-time |

### Existing Features

1. **World Map**: Leaflet.js with dark theme, city/launch site markers
2. **Missile Tracking**: 22 target cities, 5 adversary launch sites
3. **Satellite Fleet**: 8 satellites (DSP, SBIRS, GPS-III with NDS)
4. **Alert System**: Real-time alerts with DEFCON controls
5. **Intercept System**: GBI-style probability-based intercepts

### Gaps for Game Conversion

| Gap | Priority | Effort |
|-----|----------|--------|
| 3D visualization | Critical | High |
| Native desktop packaging | Critical | Medium |
| Scenario editor | High | Medium |
| Campaign/mission system | High | High |
| Audio/SFX | High | Medium |
| Steam integration | Medium | Medium |
| Multiplayer networking | Medium | High |
| Save/Load system | Medium | Low |
| AI opponent | Medium | High |
| Achievements/progression | Low | Medium |

---

## Product Vision

### Core Gameplay Loop

1. **Briefing**: Receive threat intelligence, choose defensive posture
2. **Detection**: Real-time satellite telemetry identifies launches
3. **Decision**: Allocate interceptors, assign targets, manage DEFCON
4. **Engagement**: Watch interceptors engage incoming threats
5. **Aftermath**: Assess damage, casualties, political fallout
6. **Progression**: Unlock new technologies, satellites, interceptors

### Target Audience

- Military simulation enthusiasts
- Strategy game players (DEFCON, Wargame series)
- Educators teaching nuclear deterrence
- Researchers modeling threat scenarios

### Monetization (if commercial)

| Model | Revenue | Notes |
|-------|---------|-------|
| Steam ($19.99) | Primary | One-time purchase |
| DLC Scenarios | Secondary | Historical what-ifs |
| Workshop | Free | Community scenarios |
| Educational | Free | Academic licenses |

---

## Technical Architecture

### Platform Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     GAME RUNTIME                             │
├─────────────────────────────────────────────────────────────┤
│  Unity Engine (C#)    │    Godot Engine (GDScript/C#)       │
│  ├─ High-level API    │    ├─ Open source                   │
│  ├─ Steamworks SDK    │    ├─ Lightweight                   │
│  └─ 3D/2D rendering   │    └─ Cross-platform               │
├─────────────────────────────────────────────────────────────┤
│                     NETWORKING LAYER                        │
├─────────────────────────────────────────────────────────────┤
│  Steam P2P           │    Mirror (Unity) / ENet (Godot)    │
│  ├─ Matchmaking      │    ├─ Lobby system                  │
│  ├─ P2P relay        │    ├─ Host/client model             │
│  └─ Steam servers    │    └─ Dedicated server option       │
├─────────────────────────────────────────────────────────────┤
│                     SIMULATION ENGINE                        │
├─────────────────────────────────────────────────────────────┤
│  Core (Rust/Go)       │    Port from Python                 │
│  ├─ Ballistic physics │    ├─ Accurate trajectories        │
│  ├─ Satellite models  │    ├─ DSP/SBIRS/GPS simulation     │
│  ├─ Intercept calc    │    ├─ GBI/THAAD/Patriot systems    │
│  └─ State machine     │    └─ Multi-threaded              │
├─────────────────────────────────────────────────────────────┤
│                     DATA LAYER                              │
├─────────────────────────────────────────────────────────────┤
│  SQLite (local)       │    PostgreSQL (multiplayer)        │
│  ├─ Save games        │    ├─ User accounts                │
│  ├─ Scenarios         │    ├─ Leaderboards                 │
│  ├─ Settings          │    └─ Match history                │
│  └─ Statistics        │                                     │
└─────────────────────────────────────────────────────────────┘
```

### Recommended Engine: Godot 4.x

**Reasons:**
- Open source (no licensing fees)
- Native export to Linux/Windows/macOS
- C# support for simulation logic
- Built-in networking (ENet)
- Lightweight footprint
- Active community

### Alternative: Unity 2022 LTS

**Reasons:**
- Mature Steamworks integration
- Larger asset store
- Better 3D tooling
- More multiplayer middleware

---

## Development Phases

### Phase 1: Foundation (Months 1-3)

**Goal**: Proof-of-concept with basic 3D globe and missile simulation

| Task | Owner | Est. | Priority |
|------|-------|------|----------|
| Set up Godot project structure | Dev | 1 day | P0 |
| Import globe 3D model (NASA Blue Marble) | Dev | 2 days | P0 |
| Port missile trajectory to GDScript/C# | Dev | 1 week | P0 |
| Basic camera controls (orbit, zoom) | Dev | 3 days | P0 |
| Missile spawn and trajectory render | Dev | 1 week | P1 |
| City markers (3D pins) | Dev | 2 days | P1 |
| Launch site markers | Dev | 1 day | P1 |
| Basic UI (DEFCON slider, speed control) | Dev | 1 week | P1 |
| Time scale controls (1x-100x) | Dev | 2 days | P2 |

**Deliverable**: Executable with 3D globe, missile spawns, basic controls

---

### Phase 2: Simulation Engine (Months 3-5)

**Goal**: Accurate physics, satellite systems, intercept mechanics

| Task | Owner | Est. | Priority | Status |
|------|-------|------|----------|--------|
| Accurate ballistic trajectory (Earth curvature) | Dev | 2 weeks | P0 | ✅ Done |
| Boost/midcourse/terminal phases | Dev | 1 week | P0 | ✅ Done |
| Satellite telemetry system | Dev | 2 weeks | P0 | ✅ Done |
| DSP/SBIRS detection simulation | Dev | 1 week | P1 | ✅ Done |
| GPS NDS nuclear detection | Dev | 1 week | P1 | ✅ Done |
| GBI interceptor system | Dev | 1 week | P0 | ✅ Done |
| THAAD/Patriot systems | Dev | 1 week | P1 | ✅ Done |
| Intercept probability modeling | Dev | 1 week | P1 | ✅ Done |
| Multi-intercept coordination | Dev | 1 week | P2 | ✅ Done |
| Damage assessment model | Dev | 1 week | P2 | ✅ Done |

**Deliverable**: Accurate simulation backend with all detection/intercept systems

---

### Phase 3: Scenario System (Months 5-7)

**Goal**: Create, edit, save, load scenarios

| Task | Owner | Est. | Priority | Status |
|------|-------|------|----------|--------|
| Scenario data structure (JSON) | Dev | 2 days | P0 | ✅ Done |
| Scenario editor UI | Dev | 2 weeks | P0 | 🔄 In Progress |
| Launch site placement | Dev | 1 week | P0 | ✅ Done |
| Target city selection | Dev | 1 week | P0 | ✅ Done |
| Missile type selection | Dev | 1 week | P1 | ✅ Done |
| Wave editor | Dev | 1 week | P1 | ✅ Done |
| Save/load scenarios | Dev | 3 days | P0 | ✅ Done |
| Scenario validation | Dev | 2 days | P1 | ⬜ Not Started |
| Custom scenarios folder | Dev | 1 day | P2 | ⬜ Not Started |
| Wave timing editor | Dev | 1 week | P1 |
| Save/Load system | Dev | 1 week | P0 |
| Built-in scenarios (10+) | Dev | 2 weeks | P1 |
| Scenario validation | Dev | 1 week | P2 |

**Deliverable**: Full scenario editor with save/load

---

### Phase 4: Campaign Mode (Months 7-9)

**Goal**: Structured progression with missions and unlocks

| Task | Owner | Est. | Priority |
|------|-------|------|----------|
| Campaign data structure | Dev | 1 week | P0 |
| Mission briefings (text/audio) | Dev | 2 weeks | P1 |
| Victory/defeat conditions | Dev | 1 week | P0 |
| Star/score rating system | Dev | 1 week | P1 |
| Unlock progression | Dev | 1 week | P1 |
| New satellite unlocks | Dev | 1 week | P2 |
| New interceptor unlocks | Dev | 1 week | P2 |
| Campaign map | Dev | 1 week | P2 |
| Story/cutscenes | Content | 2 weeks | P3 |

**Deliverable**: 10-mission campaign with progression

---

### Phase 5: Audio & Polish (Months 9-10)

**Goal**: Professional audio, visual effects, UI polish

| Task | Owner | Est. | Priority |
|------|-------|------|----------|
| Sound effects library | Audio | 2 weeks | P0 |
| Missile launch SFX | Audio | 1 week | P0 |
| Intercept explosion SFX | Audio | 1 week | P0 |
| Alert klaxons | Audio | 1 week | P0 |
| Ambient music | Audio | 1 week | P1 |
| UI click/feedback sounds | Audio | 1 week | P1 |
| Nuclear explosion VFX | Dev | 1 week | P0 |
| Contrail effects | Dev | 1 week | P1 |
| Satellite orbit lines | Dev | 1 week | P2 |
| CRT/scanline effects | Dev | 1 week | P2 |
| UI theming (dark military) | Dev | 2 weeks | P1 |

**Deliverable**: Polished game with full audio/visual suite

---

### Phase 6: Multiplayer (Months 10-12)

**Goal**: Online co-op and adversarial modes

| Task | Owner | Est. | Priority |
|------|-------|------|----------|
| Network architecture | Dev | 1 week | P0 |
| Steam P2P integration | Dev | 2 weeks | P0 |
| Lobby system | Dev | 1 week | P0 |
| Host/client synchronization | Dev | 2 weeks | P0 |
| Co-op mode (2-4 players) | Dev | 2 weeks | P1 |
| Adversarial mode (1v1) | Dev | 2 weeks | P1 |
| Leaderboards | Dev | 1 week | P2 |
| Match history | Dev | 1 week | P2 |
| Dedicated server option | Dev | 2 weeks | P3 |

**Deliverable**: Full multiplayer via Steam

---

### Phase 7: Steam Integration (Months 12-13)

**Goal**: Steam store page, achievements, workshop

| Task | Owner | Est. | Priority |
|------|-------|------|----------|
| Steam app ID registration | Biz | 2 weeks | P0 |
| Store page assets | Art | 1 week | P0 |
| Trailer video | Art | 2 weeks | P0 |
| Screenshots (10+) | Art | 1 week | P0 |
| Achievements (20+) | Dev | 1 week | P1 |
| Trading cards | Art | 1 week | P2 |
| Workshop integration | Dev | 2 weeks | P1 |
| Cloud saves | Dev | 1 week | P1 |
| Steam controller support | Dev | 1 week | P2 |

**Deliverable**: Live Steam store page with full integration

---

### Phase 8: Launch & Post-Launch (Month 13+)

**Goal**: Release, support, content updates

| Task | Owner | Est. | Priority |
|------|-------|------|----------|
| Beta testing | QA | 2 weeks | P0 |
| Bug fixes | Dev | Ongoing | P0 |
| Performance optimization | Dev | 2 weeks | P0 |
| Localization (ES, DE, FR, ZH, RU) | Content | 3 weeks | P1 |
| Steam launch day | Biz | 1 day | P0 |
| Marketing push | Biz | 1 week | P0 |
| Community management | Biz | Ongoing | P1 |
| DLC scenario pack 1 | Content | 4 weeks | P2 |

**Deliverable**: Launched game, first content update

---

## Detailed Task List

### Phase 1 Tasks (Detailed)

#### 1.1 Project Setup
```yaml
task: setup-godot-project
estimate: 1 day
assignee: dev
priority: P0
subtasks:
  - Create GitHub/GitLab repo
  - Initialize Godot 4.x project
  - Set up folder structure:
    - /scenes - Game scenes
    - /scripts - GDScript/C# code
    - /assets - 3D models, textures
    - /audio - Sound effects, music
    - /data - JSON scenarios, configs
  - Configure version control (.gitignore)
  - Add README.md with build instructions
```

#### 1.2 Globe Implementation
```yaml
task: implement-3d-globe
estimate: 2 days
assignee: dev
priority: P0
subtasks:
  - Download NASA Blue Marble texture (2048x1024)
  - Create sphere mesh (UV sphere, 64x32 segments)
  - Apply Earth texture with proper UV mapping
  - Add atmosphere glow shader
  - Implement cloud layer (optional)
  - Add night lights texture (optional)
```

#### 1.3 Camera System
```yaml
task: implement-camera-controls
estimate: 3 days
assignee: dev
priority: P0
subtasks:
  - Orbit camera around globe (mouse drag)
  - Zoom in/out (scroll wheel)
  - Click-to-focus on city/missile
  - Smooth camera transitions
  - Min/max zoom limits
  - Camera speed settings
```

#### 1.4 Missile Trajectory Port
```yaml
task: port-missile-physics
estimate: 1 week
assignee: dev
priority: P0
subtasks:
  - Port Missile class from Python to C#/GDScript
  - Implement great-circle trajectory
  - Add boost/midcourse/terminal phases
  - Calculate altitude over time
  - Render contrail line
  - Add missile 3D model
```

---

### Phase 2 Tasks (Detailed)

#### 2.1 Accurate Ballistics
```yaml
task: accurate-ballistic-trajectory
estimate: 2 weeks
assignee: dev
priority: P0
description: |
  Implement realistic ballistic missile physics:
  - Earth curvature (great-circle path)
  - Gravity model (simplified)
  - Atmospheric drag during boost/terminal
  - Multiple warhead (MIRV) support
  - Decoy warheads
subtasks:
  - Implement geodesic calculations
  - Add boost phase acceleration
  - Model exo-atmospheric coast
  - Add re-entry heating effects
  - Implement MIRV separation
```

#### 2.2 Satellite System
```yaml
task: satellite-telemetry-system
estimate: 2 weeks
assignee: dev
priority: P0
description: |
  Port and enhance satellite simulation:
  - DSP satellites (geostationary)
  - SBIRS enhanced IR detection
  - GPS-III with NDS (nuclear detection)
  - Realistic orbital positions
  - Detection probability by range
subtasks:
  - Create Satellite class
  - Implement orbital mechanics
  - Add IR sensor simulation
  - Add X-ray/neutron detection
  - Create satellite 3D models
```

#### 2.3 Intercept Systems
```yaml
task: intercept-systems
estimate: 2 weeks
assignee: dev
priority: P0
description: |
  Implement defensive systems:
  - GBI (Ground-Based Interceptor)
  - THAAD (Terminal High Altitude Area Defense)
  - Patriot PAC-3
  - Aegis/SM-3
subtasks:
  - Create Interceptor class
  - Implement kill probability by phase
  - Add flight time calculations
  - Model interceptor capacity
  - Create contrail effects
```

---

## File Structure

```
norad-war-simulator/
├── README.md
├── ROADMAP.md
├── LICENSE
├── godot-project/
│   ├── project.godot
│   ├── scenes/
│   │   ├── main.tscn
│   │   ├── globe.tscn
│   │   ├── ui/
│   │   │   ├── hud.tscn
│   │   │   ├── scenario_editor.tscn
│   │   │   └── briefing.tscn
│   │   └── multiplayer/
│   │       ├── lobby.tscn
│   │       └── server_browser.tscn
│   ├── scripts/
│   │   ├── simulation/
│   │   │   ├── missile.gd
│   │   │   ├── satellite.gd
│   │   │   ├── interceptor.gd
│   │   │   └── detonation.gd
│   │   ├── ui/
│   │   │   ├── hud_controller.gd
│   │   │   ├── defcon_control.gd
│   │   │   └── alert_panel.gd
│   │   ├── multiplayer/
│   │   │   ├── network_manager.gd
│   │   │   └── sync_manager.gd
│   │   └── autoload/
│   │       ├── game_state.gd
│   │       ├── settings.gd
│   │       └── audio_manager.gd
│   ├── assets/
│   │   ├── textures/
│   │   │   ├── earth/
│   │   │   │   ├── blue_marble_2048.png
│   │   │   │   ├── night_lights.png
│   │   │   │   └── clouds.png
│   │   │   └── ui/
│   │   ├── models/
│   │   │   ├── missile.glb
│   │   │   ├── interceptor.glb
│   │   │   └── satellite.glb
│   │   └── shaders/
│   │       ├── atmosphere.gdshader
│   │       └── contrail.gdshader
│   ├── audio/
│   │   ├── sfx/
│   │   │   ├── launch.wav
│   │   │   ├── intercept.wav
│   │   │   └── alert.wav
│   │   └── music/
│   │       └── ambient.ogg
│   └── data/
│       ├── scenarios/
│       │   ├── tutorial.json
│       │   ├── cold_war.json
│       │   └── ww3.json
│       ├── cities.json
│       └── launch_sites.json
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SCENARIO_FORMAT.md
│   ├── MULTIPLAYER.md
│   └── STEAM_INTEGRATION.md
├── tools/
│   ├── scenario_editor.py
│   └── asset_converter.py
└── steam/
    ├── achievements.json
    └── workshop/
```

---

## Built-in Scenarios

| # | Name | Description | Difficulty |
|---|------|-------------|------------|
| 1 | **Tutorial** | Single missile, learn controls | Easy |
| 2 | **First Alert** | 3 missiles from one site | Easy |
| 3 | **Rising Tensions** | 10 missiles, 2 sites | Medium |
| 4 | **Cuban Crisis** | Historical 1962 scenario | Medium |
| 5 | **Korean Standoff** | North Korea launches | Medium |
| 6 | **Middle East** | Regional conflict escalates | Hard |
| 7 | **Cold War Hot** | Full Soviet strike (100+) | Hard |
| 8 | **World War III** | Multi-theater, 500+ missiles | Expert |
| 9 | **Decoy Attack** | MIRV with decoys | Expert |
| 10 | **Overwhelmed** | More missiles than interceptors | Expert |

---

## Technology Decisions

### Engine: Godot 4.x

**Pros:**
- Free and open source
- Native Linux/Windows/macOS export
- C# support for simulation code
- Built-in networking
- No revenue share

**Cons:**
- Smaller asset store than Unity
- Less mature Steam integration
- Smaller community

### Alternative: Unity 2022 LTS

**Pros:**
- Mature Steamworks SDK
- Larger asset store
- More multiplayer middleware

**Cons:**
- Revenue share above threshold
- Larger runtime
- Licensing complexity

---

## Risk Register

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Engine limitations | Medium | High | Prototype early, evaluate both engines |
| Steam approval delays | Low | Medium | Submit early, have backup distribution |
| Multiplayer sync issues | Medium | High | Use proven networking library |
| Asset quality | Low | Medium | Hire contractors for key assets |
| Scope creep | High | High | Strict phase boundaries, MVP focus |

---

## Success Metrics

| Metric | Target | Phase |
|--------|--------|-------|
| Playable prototype | Basic globe + missiles | Phase 1 |
| Accurate simulation | 95% trajectory accuracy | Phase 2 |
| Scenario editor | Create/load/save working | Phase 3 |
| Campaign complete | 10 missions playable | Phase 4 |
| Steam ready | Store page approved | Phase 7 |
| Launch | >1000 sales in first week | Phase 8 |

---

## Timeline Overview

```
Month 1-3:  Phase 1 - Foundation
Month 3-5:  Phase 2 - Simulation Engine
Month 5-7:  Phase 3 - Scenario System
Month 7-9:  Phase 4 - Campaign Mode
Month 9-10: Phase 5 - Audio & Polish
Month 10-12: Phase 6 - Multiplayer
Month 12-13: Phase 7 - Steam Integration
Month 13+:  Phase 8 - Launch & Post-Launch

Total: 13 months to launch
```

---

## Next Steps

1. **Immediate** (This Week):
   - [ ] Create GitLab repository: `norad-war-simulator`
   - [ ] Choose engine (Godot recommended)
   - [ ] Set up project structure
   - [ ] Download Earth textures (NASA Blue Marble)

2. **Short-term** (Next 2 Weeks):
   - [ ] Implement 3D globe with camera controls
   - [ ] Port basic missile trajectory
   - [ ] Create first playable prototype

3. **Medium-term** (Month 1):
   - [ ] Complete Phase 1 milestone
   - [ ] Begin Phase 2 simulation work
   - [ ] Recruit additional developers (if needed)

---

*Last Updated: 2026-03-31*
*Version: 1.0*