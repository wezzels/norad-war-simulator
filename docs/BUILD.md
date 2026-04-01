# Build Instructions

## Prerequisites

- Godot 4.2+ (standard desktop edition)
- No C#/.NET required (pure GDScript)

## Installing Godot

### Linux

```bash
# Flatpak (recommended)
flatpak install flathub org.godotengine.Godot

# Snap
snap install godot
```

### Windows

Download from https://godotengine.org/download/windows/

### macOS

```bash
brew install --cask godot
```

## Building

### All Platforms

```bash
./build.sh
```

This creates:
- `export/linux/norad-war-simulator-VERSION-linux.tar.gz`
- `export/windows/norad-war-simulator-VERSION-windows.zip`
- `export/macos/norad-war-simulator-VERSION-macos.zip`
- `export/norad-war-simulator-VERSION-src.tar.gz`

### Individual Platforms

```bash
# Linux only
godot --headless --export-release "Linux/X11" export/linux/game.tar.gz

# Windows only
godot --headless --export-release "Windows Desktop" export/windows/game.zip

# macOS only
godot --headless --export-release "macOS" export/macos/game.zip
```

## Development

### Running in Editor

```bash
godot project.godot
```

### Running from Command Line

```bash
godot --path . scenes/main.tscn
```

### Testing

```bash
# Run tests
godot --headless --script tests/test_physics.gd
```

## Export Templates

Export templates must be installed for each target platform.

1. Open Godot Editor
2. Editor → Manage Export Templates
3. Download and install templates for all platforms

## Release Process

1. Update version in `project.godot`
2. Update version in `build.sh`
3. Update `RELEASE_NOTES.md`
4. Run `./build.sh`
5. Create GitHub release with binaries

## Troubleshooting

### "Export template not found"

Install export templates via Editor → Manage Export Templates

### Build fails on Linux

Ensure you have the X11 export template installed.

### Windows build fails on Linux

You need the Windows export template and Wine may be required for some features.