# Phased Task List - NORAD War Simulator

**Created**: 2026-03-31
**Status**: Planning
**Total Estimate**: 13 months

---

## Phase 1: Foundation (Months 1-3)

### Week 1-2: Project Setup

- [ ] **1.1** Create GitLab repository `norad-war-simulator`
  - Initialize repo with README.md, ROADMAP.md
  - Set up branch protection (main)
  - Add issue labels (bug, feature, docs)
  - Create milestone: "Phase 1 - Foundation"

- [ ] **1.2** Set up Godot 4.x project
  - Install Godot 4.x (C# version)
  - Create project structure:
    ```
    /scenes - Game scenes
    /scripts - GDScript/C# code
    /assets - 3D models, textures
    /audio - Sound effects, music
    /data - JSON scenarios
    ```
  - Configure version control
  - Add .gitignore for Godot

- [ ] **1.3** Download Earth assets
  - NASA Blue Marble texture (2048x1024)
  - Night lights texture
  - Cloud layer texture
  - Bump/normal maps (optional)

### Week 3-4: 3D Globe

- [ ] **1.4** Create Earth sphere
  - UV sphere mesh (64x32 segments)
  - Apply Earth texture with UV mapping
  - Add atmosphere glow shader
  - Add cloud layer (separate mesh)
  - Add night lights overlay

- [ ] **1.5** Implement camera system
  - Orbit controls (mouse drag)
  - Zoom in/out (scroll wheel)
  - Click-to-focus on objects
  - Smooth camera transitions (lerp)
  - Min/max zoom limits
  - Camera settings panel

### Week 5-6: Basic Missile System

- [ ] **1.6** Port Missile class from Python
  - Convert to C#/GDScript
  - Implement properties:
    - id, origin, target, type
    - altitude, speed, progress
    - flight_time, warhead_yield
  - Add trajectory calculation

- [ ] **1.7** Implement trajectory rendering
  - Great-circle path calculation
  - Draw contrail line
  - Animate missile along path
  - Add missile 3D model
  - Scale by altitude

### Week 7-8: UI Foundation

- [ ] **1.8** Create HUD scene
  - DEFCON level display (1-5)
  - Speed controls (1x-10x)
  - Pause/Play button
  - Alert panel (scrolling)
  - Statistics panel

- [ ] **1.9** Add city markers
  - 22 target cities from original
  - 3D pins on globe
  - Click for city info
  - Highlight on hover

- [ ] **1.10** Add launch site markers
  - 5 adversary launch sites
  - Different color/style
  - Click for site info

### Week 9-10: Integration

- [ ] **1.11** Wire up simulation loop
  - Timer-based updates
  - State synchronization
  - Speed controls work
  - Pause/resume works

- [ ] **1.12** Build first prototype
  - Export to Linux
  - Export to Windows
  - Test on both platforms
  - Document build process

### Phase 1 Deliverables

| Deliverable | Status |
|-------------|--------|
| 3D Earth globe | Pending |
| Camera controls | Pending |
| Basic missile trajectory | Pending |
| City/launch markers | Pending |
| HUD prototype | Pending |
| Linux build | Pending |
| Windows build | Pending |

---

## Phase 2: Simulation Engine (Months 3-5)

### Week 11-12: Ballistic Physics

- [ ] **2.1** Accurate trajectory calculation
  - Earth curvature (geodesic)
  - Gravity model
  - Boost phase acceleration
  - Exo-atmospheric coast
  - Re-entry physics

- [ ] **2.2** Trajectory phases
  - Boost (0-10% progress)
  - Midcourse (10-80%)
  - Terminal (80-100%)
  - Phase-specific behavior

### Week 13-14: MIRV & Decoys

- [ ] **2.3** Multiple warheads
  - MIRV bus separation
  - Individual warhead tracking
  - Different targets per warhead

- [ ] **2.4** Decoy warheads
  - Decoy types (balloon, chaff)
  - Detection difficulty
  - Interceptor confusion

### Week 15-16: Satellite System

- [ ] **2.5** Port satellite data
  - DSP satellites (3)
  - SBIRS satellites (2)
  - GPS-III with NDS (3)
  - Orbital positions

- [ ] **2.6** Detection simulation
  - IR intensity detection
  - X-ray flux measurement
  - Neutron counting
  - Detection probability by range

- [ ] **2.7** Satellite visualization
  - 3D models in orbit
  - Coverage circles
  - Status indicators
  - Click for telemetry

### Week 17-18: Intercept Systems

- [ ] **2.8** GBI interceptor
  - Ground-Based Interceptor
  - Launch sites (Alaska, California)
  - Kill probability by phase
  - Flight time calculation

- [ ] **2.9** THAAD system
  - Terminal High Altitude Defense
  - Deployment locations
  - Range/altitude limits

- [ ] **2.10** Patriot PAC-3
  - Point defense
  - Lower altitude intercept
  - Multiple engagement

- [ ] **2.11** Aegis/SM-3
  - Naval-based interceptors
  - Ship positioning
  - Coverage area

### Week 19-20: Damage Assessment

- [ ] **2.12** Detonation model
  - Yield vs distance
  - Blast radius
  - Thermal pulse
  - Fallout plume (simplified)

- [ ] **2.13** Casualty estimation
  - Population density
  - Shelter factor
  - Time of day factor

### Phase 2 Deliverables

| Deliverable | Status |
|-------------|--------|
| Accurate ballistic physics | Pending |
| MIRV/decoy support | Pending |
| Satellite system | Pending |
| All interceptors | Pending |
| Damage model | Pending |

---

## Phase 3: Scenario System (Months 5-7)

### Week 21-22: Scenario Format

- [ ] **3.1** Design JSON schema
  ```json
  {
    "name": "Scenario Name",
    "description": "...",
    "difficulty": 1-5,
    "launch_sites": [...],
    "missile_waves": [...],
    "interceptors": {...},
    "victory_conditions": {...}
  }
  ```

- [ ] **3.2** Create scenario loader
  - Parse JSON
  - Validate structure
  - Load into game state
  - Error handling

### Week 23-24: Scenario Editor

- [ ] **3.3** Editor UI scene
  - Tab-based interface
  - Launch sites tab
  - Missile waves tab
  - Interceptors tab
  - Victory conditions tab

- [ ] **3.4** Launch site editor
  - Add/remove sites
  - Set position on globe
  - Configure missile types

- [ ] **3.5** Wave editor
  - Add/remove waves
  - Set timing
  - Configure missiles per wave
  - Target assignment

### Week 25-26: Save/Load

- [ ] **3.6** Save system
  - Serialize to JSON
  - File dialog
  - Autosave draft

- [ ] **3.7** Load system
  - File browser
  - Preview metadata
  - Validation

### Week 27-28: Built-in Scenarios

- [ ] **3.8** Create 10 scenarios
  1. Tutorial (1 missile)
  2. First Alert (3 missiles)
  3. Rising Tensions (10 missiles)
  4. Cuban Crisis (historical)
  5. Korean Standoff
  6. Middle East
  7. Cold War Hot (100+)
  8. World War III (500+)
  9. Decoy Attack
  10. Overwhelmed

### Phase 3 Deliverables

| Deliverable | Status |
|-------------|--------|
| Scenario JSON format | Pending |
| Scenario editor | Pending |
| Save/Load system | Pending |
| 10 built-in scenarios | Pending |

---

## Phase 4: Campaign Mode (Months 7-9)

### Week 29-30: Campaign Structure

- [ ] **4.1** Campaign data model
  - Mission list
  - Unlock tree
  - Progress tracking

- [ ] **4.2** Campaign UI
  - Mission select screen
  - Briefing screen
  - After-action report

### Week 31-32: Mission System

- [ ] **4.3** Victory conditions
  - Cities saved threshold
  - Time limit (optional)
  - Interceptor efficiency

- [ ] **4.4** Star rating
  - 1-3 stars per mission
  - Based on performance
  - Unlock requirements

### Week 33-34: Progression

- [ ] **4.5** Unlock system
  - New satellites
  - New interceptors
  - New scenarios

- [ ] **4.6** Save progression
  - Local save
  - Per-user profile

### Week 35-36: 10 Mission Campaign

- [ ] **4.7** Create campaign missions
  - Story arc
  - Increasing difficulty
  - Unlock progression

- [ ] **4.8** Briefings
  - Text briefings
  - Intel photos
  - Objectives list

### Phase 4 Deliverables

| Deliverable | Status |
|-------------|--------|
| Campaign structure | Pending |
| Mission system | Pending |
| Progression/unlocks | Pending |
| 10-mission campaign | Pending |

---

## Phase 5: Audio & Polish (Months 9-10)

### Week 37-38: Sound Effects

- [ ] **5.1** Core SFX
  - Missile launch
  - Intercept explosion
  - Nuclear detonation
  - Alert klaxons
  - UI clicks

- [ ] **5.2** Ambient audio
  - Background hum
  - Radio chatter
  - Warning tones

### Week 39-40: Visual Effects

- [ ] **5.3** Particle effects
  - Missile exhaust
  - Intercept explosion
  - Nuclear flash

- [ ] **5.4** Post-processing
  - Bloom
  - Screen shake
  - Scanline effect (optional)

### Week 41-42: UI Polish

- [ ] **5.5** Theme system
  - Dark military theme
  - Consistent colors
  - Font selection

- [ ] **5.6** Animations
  - Panel transitions
  - Button hover states
  - Loading screens

### Phase 5 Deliverables

| Deliverable | Status |
|-------------|--------|
| Sound effects | Pending |
| Visual effects | Pending |
| UI polish | Pending |

---

## Phase 6: Multiplayer (Months 10-12)

### Week 43-44: Network Foundation

- [ ] **6.1** Steam P2P integration
  - Steamworks SDK
  - P2P networking
  - Authentication

- [ ] **6.2** Lobby system
  - Create lobby
  - Join lobby
  - Ready system
  - Game settings

### Week 45-46: Synchronization

- [ ] **6.3** State sync
  - Authoritative server
  - Client prediction
  - Lag compensation

- [ ] **6.4** Entity replication
  - Missiles
  - Interceptors
  - Detonations

### Week 47-48: Game Modes

- [ ] **6.5** Co-op mode
  - 2-4 players
  - Shared interceptors
  - Shared responsibility

- [ ] **6.6** Adversarial mode
  - 1v1
  - Attacker vs defender
  - Score-based victory

### Phase 6 Deliverables

| Deliverable | Status |
|-------------|--------|
| Steam P2P | Pending |
| Lobby system | Pending |
| State sync | Pending |
| Co-op mode | Pending |
| Adversarial mode | Pending |

---

## Phase 7: Steam Integration (Months 12-13)

### Week 49-50: Steam Setup

- [ ] **7.1** Steam app registration
  - Submit app ID request
  - Pay $100 fee
  - Configure app settings

- [ ] **7.2** Store page
  - Write description
  - Upload screenshots
  - Create trailer
  - Set pricing

### Week 51-52: Steam Features

- [ ] **7.3** Achievements (20+)
  - Tutorial complete
  - Campaign complete
  - Various milestones
  - Hidden achievements

- [ ] **7.4** Cloud saves
  - Sync progression
  - Sync settings
  - Cross-platform

- [ ] **7.5** Workshop
  - Upload scenarios
  - Download scenarios
  - Rating system

### Phase 7 Deliverables

| Deliverable | Status |
|-------------|--------|
| Steam app ID | Pending |
| Store page | Pending |
| Achievements | Pending |
| Cloud saves | Pending |
| Workshop | Pending |

---

## Phase 8: Launch & Post-Launch (Month 13+)

### Week 53-54: Beta Testing

- [ ] **8.1** Closed beta
  - Invite testers
  - Collect feedback
  - Bug fixes

- [ ] **8.2** Open beta
  - Public announcement
  - Larger test group
  - Stress test multiplayer

### Week 55-56: Launch

- [ ] **8.3** Launch day
  - Release build
  - Marketing push
  - Community management

- [ ] **8.4** Day 1 patch
  - Critical bug fixes
  - Hotfix deployment

### Post-Launch

- [ ] **8.5** Localization
  - Spanish
  - German
  - French
  - Chinese
  - Russian

- [ ] **8.6** DLC planning
  - Scenario Pack 1
  - Campaign expansion

---

## Summary

| Phase | Duration | Status |
|-------|----------|--------|
| 1. Foundation | 10 weeks | Not Started |
| 2. Simulation | 10 weeks | Not Started |
| 3. Scenarios | 8 weeks | Not Started |
| 4. Campaign | 8 weeks | Not Started |
| 5. Polish | 6 weeks | Not Started |
| 6. Multiplayer | 6 weeks | Not Started |
| 7. Steam | 4 weeks | Not Started |
| 8. Launch | 4+ weeks | Not Started |

**Total: 56+ weeks (~13 months)**

---

*Last Updated: 2026-03-31*