# NORAD War Simulator

A cross-platform nuclear command simulation game built with Godot 4.2.

![Version](https://img.shields.io/badge/version-0.5.0--alpha-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey)

## Overview

NORAD War Simulator puts you in command of strategic missile defense. Monitor global threats via satellite early warning systems, coordinate interceptor launches, and protect your cities from nuclear devastation.

## Features

### Core Gameplay
- **Globe-based simulation** - Realistic Earth model with accurate geography
- **Ballistic physics** - True-to-life missile trajectories (boost, midcourse, terminal phases)
- **Satellite detection** - DSP, SBIRS, GPS-III early warning network
- **Multiple interceptor types** - GBI, THAAD, Patriot with different capabilities
- **DEFCON system** - Escalate readiness as threats evolve

### Game Modes
- **Scenarios** - 6 built-in scenarios from tutorials to global war
- **Campaign** - 8-mission campaign with tech tree progression
- **Scenario Editor** - Create and share custom scenarios
- **Multiplayer** - Co-op (team defense) and Versus (competing teams)

### Steam Integration
- 18 achievements
- Cloud saves
- Workshop support for custom scenarios
- Leaderboards

## Screenshots

*Coming soon*

## Installation

### Pre-built Releases

Download from [Releases](https://github.com/Wezzels/norad-war-simulator/releases) page.

### Build from Source

```bash
# Clone the repository
git clone https://github.com/Wezzels/norad-war-simulator.git
cd norad-war-simulator

# Install Godot 4.2+
# Linux:
flatpak install flathub org.godotengine.Godot

# Build all platforms
./build.sh
```

### Requirements

- Godot 4.2+ (for building)
- No C#/.NET required (pure GDScript)

## Project Status

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Foundation | ✅ Complete |
| 2 | Simulation Engine | ✅ Complete |
| 3 | Scenario System | ✅ Complete |
| 4 | Campaign Mode | ✅ Complete |
| 5 | Polish | ✅ Complete |
| 6 | Multiplayer | ✅ Complete |
| 7 | Steam Integration | ✅ Complete |
| 8 | Launch | 🔄 In Progress |

## Documentation

- [BUILD.md](docs/BUILD.md) - Detailed build instructions
- [CONTRIBUTING.md](docs/CONTRIBUTING.md) - Contribution guidelines
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Code architecture overview

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Developed by Wezzels

Built with:
- [Godot Engine](https://godotengine.org/) 4.2
- NASA Blue Marble textures
- Open game audio assets

## Support

- [Issue Tracker](https://github.com/Wezzels/norad-war-simulator/issues)
- [Discussions](https://github.com/Wezzels/norad-war-simulator/discussions)

---

*"The only winning move is not to play."* - WOPR