# Running NORAD War Simulator

## Prerequisites

- **Godot 4.2+** (download from https://godotengine.org)
- No C#/.NET required for current version (pure GDScript)

## Quick Start

### 1. Install Godot

```bash
# Linux (Flatpak)
flatpak install flathub org.godotengine.Godot

# Linux (Snap)
snap install godot

# Linux (Manual)
wget https://github.com/godotengine/godot/releases/download/4.2.2-stable/Godot_v4.2.2-stable_linux.x86_64.zip
unzip Godot_v4.2.2-stable_linux.x86_64.zip
./Godot_v4.2.2_stable_linux.x86_64
```

### 2. Open Project

1. Launch Godot
2. Click "Import"
3. Navigate to `norad-war-simulator/project.godot`
4. Click "Import and Edit"

### 3. Run

- Press **F5** or click the **Play** button (▶️)
- The main menu should appear

## Controls

| Control | Action |
|---------|--------|
| Mouse Drag | Orbit camera |
| Scroll | Zoom in/out |
| WASD | Camera orbit |
| Space | Launch test missile (debug) |
| 1-9 | Set game speed (1x-9x) |
| 0 | Reset speed to 1x |
| Escape | Pause |

## Project Structure

```
norad-war-simulator/
├── project.godot          # Godot project config
├── icon.svg              # App icon
├── scenes/               # Godot scenes
│   ├── main.tscn        # Root scene
│   ├── main_menu.tscn   # Main menu
│   ├── scenario_select.tscn
│   ├── game.tscn        # Main game
│   ├── missile.tscn
│   ├── interceptor.tscn
│   ├── detonation.tscn
│   └── effects/         # Particle effects
├── scripts/              # GDScript files
│   ├── autoload/        # Global scripts
│   ├── simulation/      # Game logic
│   ├── globe/           # 3D globe
│   ├── ui/              # UI controllers
│   └── systems/         # Game systems
├── data/                 # JSON data files
└── assets/               # Textures, models, audio
```

## Troubleshooting

### "Failed to load resource"

Some assets may not be complete. The project should still run without them.

### Missing Audio

Audio files are placeholders. The game will work but without sound effects.

### Black Screen

1. Check that `res://scenes/main.tscn` is set as the main scene
2. Look for errors in the Output panel

## Development

### Adding New Scenarios

1. Create JSON file in `data/scenarios/`
2. Follow format in existing scenarios
3. Add to `scenario_select.gd` scenarios array

### Adding New Cities

Edit `data/cities.json`:
```json
{"name": "City Name", "lat": 0.0, "lon": 0.0, "population": 1000000, "country": "Country"}
```

### Adding Launch Sites

Edit `data/launch_sites.json`:
```json
{"name": "Site Name", "lat": 0.0, "lon": 0.0, "country": "Country", "type": "adversary"}
```

## Building for Release

```bash
# In Godot:
# Project → Export...
# Add preset for target platform
# Export Project
```

See ROADMAP.md for release timeline.