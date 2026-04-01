# Contributing to NORAD War Simulator

Thank you for your interest in contributing!

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/wezzels/norad-war-simulator.git
   cd norad-war-simulator
   ```

2. **Install Godot 4.2+**
   - Download from [godotengine.org](https://godotengine.org/download)
   - Or via package manager:
     ```bash
     # Linux (Flatpak)
     flatpak install flathub org.godotengine.Godot
     
     # Linux (Snap)
     snap install godot
     ```

3. **Open the project**
   ```bash
   godot project.godot
   ```

## Project Structure

```
norad-war-simulator/
├── scenes/           # Godot scene files (.tscn)
├── scripts/          # GDScript files (.gd)
│   ├── autoload/     # Global singletons
│   ├── effects/      # Visual effects
│   ├── globe/        # Globe rendering
│   ├── simulation/   # Game logic
│   ├── systems/      # Core systems
│   └── ui/           # User interface
├── assets/            # Art assets
│   ├── textures/     # Images
│   └── audio/        # Sound files
├── data/              # JSON data files
├── themes/            # UI themes
└── tests/             # Test files
```

## Coding Standards

### GDScript

- Use `##` for documentation comments (shown in editor)
- Use `#` for regular comments
- Use snake_case for variables and functions
- Use PascalCase for classes and nodes
- Keep functions under 50 lines when possible
- Use type hints: `var name: String` instead of `var name`

### Example

```gdscript
## missile.gd
## Handles missile movement and physics
class_name Missile

extends Node3D

# Signals
signal impact(target: Dictionary)

# Properties
var speed: float = 5000.0
var target: Dictionary = {}

# Methods
func _process(delta: float) -> void:
    move_towards_target(delta)

func move_towards_target(delta: float) -> void:
    # Implementation
    pass
```

## Branches

- `main` - Stable releases
- `develop` - Active development
- `feature/*` - New features
- `fix/*` - Bug fixes

## Pull Requests

1. Fork the repository
2. Create a feature branch (`feature/my-feature`)
3. Make your changes
4. Test thoroughly
5. Submit a pull request with:
   - Description of changes
   - Screenshots (if UI changes)
   - Testing instructions

## Issues

Found a bug? Have a suggestion?

1. Check [existing issues](https://github.com/wezzels/norad-war-simulator/issues)
2. If not found, create a new issue with:
   - Clear title
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Screenshots (if applicable)
   - Your system info (OS, Godot version)

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

*"The only winning move is not to play."* - WOPR