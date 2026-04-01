# Architecture Overview

This document describes the high-level architecture of NORAD War Simulator.

## Engine

Built with **Godot 4.2** using pure GDScript (no C#/.NET required).

## Directory Structure

```
norad-war-simulator/
├── project.godot           # Godot project file
├── build.sh              # Build script
├── README.md             # Project overview
├── LICENSE               # MIT License
│
├── scenes/               # Godot scene files
│   ├── main.tscn        # Entry point
│   ├── game.tscn        # Main game scene
│   ├── main_menu.tscn   # Main menu
│   ├── campaign_menu.tscn
│   ├── scenario_editor.tscn
│   ├── multiplayer_menu.tscn
│   ├── lobby_menu.tscn
│   └── ...
│
├── scripts/              # GDScript files
│   ├── autoload/        # Global singletons
│   │   ├── main.gd      # Scene management
│   │   ├── game_state.gd # Game state manager
│   │   ├── settings.gd   # User settings
│   │   └── audio_manager.gd
│   │
│   ├── globe/           # Globe rendering
│   │   ├── globe_renderer.gd
│   │   └── camera_controller.gd
│   │
│   ├── simulation/      # Game objects
│   │   ├── missile.gd
│   │   ├── interceptor.gd
│   │   ├── detonation.gd
│   │   └── game_controller.gd
│   │
│   ├── systems/         # Core systems
│   │   ├── ballistic_physics.gd
│   │   ├── satellite_system.gd
│   │   ├── damage_model.gd
│   │   ├── defense_manager.gd
│   │   ├── detection_manager.gd
│   │   ├── save_manager.gd
│   │   ├── scenario_manager.gd
│   │   ├── campaign_manager.gd
│   │   ├── network_manager.gd
│   │   ├── game_mode.gd
│   │   ├── state_sync.gd
│   │   └── steam_manager.gd
│   │
│   ├── ui/              # User interface
│   │   ├── main_menu.gd
│   │   ├── hud_controller.gd
│   │   ├── pause_menu.gd
│   │   ├── settings_menu.gd
│   │   ├── campaign_menu.gd
│   │   ├── multiplayer_menu.gd
│   │   └── ...
│   │
│   └── effects/         # Visual effects
│       └── explosion_effects.gd
│
├── themes/              # UI themes
│   └── game_theme.tres
│
├── assets/              # Art assets
│   ├── textures/        # Images
│   └── audio/           # Sound files
│       ├── sfx/        # Sound effects
│       └── music/      # Music tracks
│
├── data/                # JSON data files
│   ├── scenarios/       # Scenario definitions
│   ├── cities.json      # City data
│   ├── launch_sites.json
│   └── satellites.json
│
└── tests/               # Test files
    └── test_physics.gd
```

## Autoloads (Global Singletons)

These scripts are loaded automatically and available globally:

| Autoload | Purpose |
|----------|---------|
| `Main` | Scene management, transitions |
| `GameState` | Game state, missiles, interceptors |
| `Settings` | User preferences (graphics, audio) |
| `AudioManager` | Sound effects and music |
| `NetworkManager` | Multiplayer networking |
| `GameMode` | Co-op/Versus game modes |
| `StateSync` | Network state synchronization |
| `SteamManager` | Steam integration |
| `DefenseManager` | Interceptor inventory |
| `Ballistics` | Ballistic physics calculations |
| `Satellites` | Satellite early warning |
| `Damage` | Nuclear damage model |
| `CampaignManager` | Campaign progression |
| `Statistics` | Game statistics |

## Core Systems

### Ballistic Physics (`ballistic_physics.gd`)

Calculates realistic missile trajectories:
- Great circle distance between points
- Flight time estimates
- Position at time t (boost/midcourse/terminal phases)
- Intercept probability

### Game State (`game_state.gd`)

Manages all active entities:
- Missiles (threats)
- Interceptors (defenses)
- Detonations
- Satellites
- Alerts
- Statistics

### Defense Manager (`defense_manager.gd`)

Handles interceptor inventory:
- GBI (Ground-Based Interceptors)
- THAAD (Terminal High Altitude Area Defense)
- Patriot (point defense)
- Shoot-look-shoot doctrine

### Campaign Manager (`campaign_manager.gd`)

Manages campaign progression:
- 8 missions with increasing difficulty
- Tech tree upgrades
- Mission unlocking
- Campaign save/load

### Network Manager (`network_manager.gd`)

Handles multiplayer:
- ENet host/join
- Player management
- State synchronization
- RPC functions

## Data Flow

```
User Input → UI → GameState → Systems → Visuals
                    ↓
              Network Sync (multiplayer)
                    ↓
              Steam (achievements/cloud)
```

## Scene Transitions

```
main.tscn (root)
  └── main_menu.tscn
        ├── new_game → scenario_select.tscn → game.tscn
        ├── campaign → campaign_menu.tscn → mission_briefing.tscn → game.tscn
        ├── multiplayer → multiplayer_menu.tscn → lobby_menu.tscn → game.tscn
        └── workshop → workshop_browser.tscn
```

## Performance Considerations

- Globe uses LOD (Level of Detail) for distant viewing
- Particle systems are pooled
- State sync runs at 20Hz (configurable)
- Audio uses pool of AudioStreamPlayer nodes

## Extending the Game

### Adding a New Scenario

1. Create JSON file in `data/scenarios/my_scenario.json`
2. Define waves, interceptors, cities
3. Validate with `ScenarioValidator`
4. Test in game

### Adding a New Interceptor Type

1. Add definition in `DefenseManager`
2. Set properties (range, speed, success_rate)
3. Add visual in `interceptor.tscn`
4. Update UI to show new type

### Adding a New Achievement

1. Add definition in `SteamManager.achievements`
2. Call `SteamManager.unlock_achievement("ACHIEVEMENT_ID")` when earned
3. Test achievement unlock flow

---

For questions or contributions, see [CONTRIBUTING.md](CONTRIBUTING.md).