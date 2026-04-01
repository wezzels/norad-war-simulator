# Contributing to NORAD War Simulator

Thank you for your interest in contributing! This document will help you get started.

## Development Status

The project is currently in **Phase 1: Foundation**. Core systems are being built and the architecture is evolving. Contributions are welcome, but expect frequent changes.

## Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Open** in Godot 4.2+
4. **Create** a feature branch

```bash
git checkout -b feature/your-feature-name
```

## Code Style

### GDScript

```gdscript
## File header comment describing the class
## Second line for additional details

extends Node

class_name MyClass

# Signals
signal my_signal(param: String)

# Constants
const MY_CONSTANT: int = 42

# Enums
enum State { IDLE, ACTIVE, PAUSED }

# Exports
@export var my_property: String = "default"

# Variables
var my_variable: int = 0

# Nodes
@onready var my_node: Node = $MyNode


func _ready() -> void:
	# Initialize
	pass


func my_function(param: String) -> bool:
	"""Brief description of function"""
	return true


# Private functions start with underscore
func _private_function() -> void:
	pass
```

### Naming Conventions

- **Files**: `snake_case.gd`
- **Classes**: `PascalCase`
- **Functions**: `snake_case`
- **Variables**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Signals**: `snake_case`

## Project Structure

```
scripts/
├── autoload/     # Global singletons (GameState, Settings, etc.)
├── simulation/   # Game simulation (missiles, interceptors)
├── globe/        # 3D globe rendering
├── ui/           # UI controllers
└── systems/      # Game systems (scenarios, defense)

scenes/
├── main.tscn     # Root scene
├── main_menu.tscn
├── game.tscn
└── effects/      # Particle effects
```

## Adding Content

### New Scenario

1. Create `data/scenarios/my_scenario.json`
2. Follow existing scenario format
3. Add to `scripts/ui/scenario_select.gd`

### New City

Add to `data/cities.json`:
```json
{
  "name": "City Name",
  "lat": 0.0,
  "lon": 0.0,
  "population": 1000000,
  "country": "Country"
}
```

### New Launch Site

Add to `data/launch_sites.json`:
```json
{
  "name": "Site Name",
  "lat": 0.0,
  "lon": 0.0,
  "country": "Country",
  "type": "adversary"
}
```

## Testing

Currently there are no automated tests. Before submitting:

1. **Run** the project in Godot
2. **Play** through at least one scenario
3. **Check** for errors in the Output panel
4. **Test** edge cases (pause, speed changes, multiple missiles)

## Commit Guidelines

### Commit Messages

```
type: brief description

Detailed explanation if needed.

- Bullet points for multiple changes
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

### Example

```
feat: add THAAD interceptor type

Implement THAAD as a medium-range interceptor with:
- 200km range
- 150km max altitude
- 60% base intercept probability

- Add THAAD to TYPE_STATS in interceptor.gd
- Update defense_manager.gd to support THAAD
- Add THAAD sites to DEFENSE_SITES
```

## Pull Requests

1. **Ensure** your code follows the style guide
2. **Test** your changes thoroughly
3. **Update** documentation if needed
4. **Create** a pull request with:
   - Clear description
   - Related issue (if any)
   - Screenshots (if UI changes)

## Questions?

- Open an issue for bugs or feature requests
- Check existing issues before creating new ones
- Be respectful and constructive

## License

By contributing, you agree that your contributions will be licensed under the MIT License.