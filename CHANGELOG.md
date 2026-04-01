# Changelog

All notable changes to NORAD War Simulator will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0-alpha] - 2026-04-01

### Added - Phase 5: Polish
- Multi-stage explosion effects (fireball, smoke, shockwave)
- Contrail effects for missiles
- Impact effects for interceptions
- Mushroom cloud effects for detonations
- Button hover/press animations
- UI theme system (`game_theme.tres`)
- Loading screen with fade animations
- Procedurally generated audio effects (sox)
- Audio manager with sound pooling

### Added - Phase 6: Multiplayer
- ENet multiplayer networking (`network_manager.gd`)
- Host/Join game functionality
- Player lobby with chat system
- Ready status system
- Game mode selection (Co-op/Versus)
- Team assignment for Versus mode
- State synchronization with interpolation
- Client-side prediction

### Added - Phase 7: Steam Integration
- 18 achievements (campaign, defense, DEFCON, tech, multiplayer)
- Stats tracking (intercepts, cities saved, missions completed)
- Cloud save/load system
- Workshop browser (`workshop_browser.gd/tscn`)
- Scenario upload/subscribe/download
- Leaderboards (`leaderboard_screen.gd/tscn`)
- Multiple leaderboard categories

### Added - Phase 8: Launch
- Cross-platform build script (`build.sh`)
- MIT License
- README with installation instructions
- BUILD.md with detailed build guide
- CONTRIBUTING.md for contributors
- ARCHITECTURE.md for developers
- Steam store page draft

### Changed
- Improved main menu with animations
- Better HUD layout with styled panels
- Settings menu with button animations

### Fixed
- Various UI polish issues

## [0.4.0-alpha] - 2026-03-31

### Added - Phase 4: Campaign
- 8-mission campaign with progression
- Tech tree (GBI, THAAD, Patriot, SBIRS upgrades)
- Campaign manager autoload
- Mission briefing screen
- Debriefing/results screen
- Victory screen for campaign completion
- Campaign save/load

## [0.3.0-alpha] - 2026-03-30

### Added - Phase 3: Scenarios
- Scenario editor (`scenario_editor.gd/tscn`)
- Wave editor for missile waves
- Scenario validator
- Scenario manager
- 6 built-in scenarios
- Custom scenario support

## [0.2.0-alpha] - 2026-03-29

### Added - Phase 2: Simulation Engine
- Ballistic physics (`ballistic_physics.gd`)
- Satellite early warning (DSP, SBIRS, GPS-III)
- Damage model with blast radius
- Defense manager with shoot-look-shoot
- Detection manager for satellites
- Save manager (10 slots + autosave)
- Audio placeholder system

## [0.1.0-alpha] - 2026-03-28

### Added - Phase 1: Foundation
- Godot 4.2 project structure
- Globe renderer with NASA Blue Marble textures
- Orbital camera controller
- Missile and interceptor visuals
- HUD with DEFCON display
- Main menu and scenario selection
- Project foundation

---

## Release Naming

- **Major (X.0.0)**: Breaking changes, major new features
- **Minor (0.X.0)**: New features, backwards compatible
- **Patch (0.0.X)**: Bug fixes, minor improvements
- **Pre-release**: `-alpha`, `-beta`, `-rc` suffixes

## Upcoming

### [0.6.0-alpha] - Planned
- Performance optimizations
- Additional scenarios
- More interceptor types
- Satellite upgrades visual effects

### [1.0.0] - Future
- Steam release
- Full campaign
- Multiplayer stability
- Localization (German, French, Spanish, Russian, Chinese)