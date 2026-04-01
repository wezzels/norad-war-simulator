#!/bin/bash
# build.sh - Build NORAD War Simulator for all platforms
# Requires Godot 4.2+ to be installed

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$PROJECT_DIR/export"
VERSION="0.5.0-alpha"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== NORAD War Simulator Build Script ===${NC}"
echo "Version: $VERSION"
echo ""

# Check for Godot
check_godot() {
    if command -v godot4 &> /dev/null; then
        GODOT="godot4"
    elif command -v godot &> /dev/null; then
        GODOT="godot"
    elif [ -f "/usr/bin/godot4" ]; then
        GODOT="/usr/bin/godot4"
    elif [ -f "$HOME/.local/bin/godot4" ]; then
        GODOT="$HOME/.local/bin/godot4"
    else
        echo -e "${RED}Error: Godot not found${NC}"
        echo "Please install Godot 4.2+"
        echo "  flatpak install flathub org.godotengine.Godot"
        echo "  or"
        echo "  snap install godot"
        exit 1
    fi
    echo -e "${GREEN}Found Godot: $GODOT${NC}"
}

# Create export directory
prepare_export_dir() {
    echo -e "${YELLOW}Preparing export directory...${NC}"
    mkdir -p "$EXPORT_DIR"
    mkdir -p "$EXPORT_DIR/linux"
    mkdir -p "$EXPORT_DIR/windows"
    mkdir -p "$EXPORT_DIR/macos"
}

# Build for Linux
build_linux() {
    echo -e "${YELLOW}Building for Linux/X11...${NC}"
    
    $GODOT --headless --export-release "Linux/X11" "$EXPORT_DIR/linux/norad-war-simulator-$VERSION-linux.tar.gz"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Linux build complete${NC}"
        ls -lh "$EXPORT_DIR/linux/"
    else
        echo -e "${RED}Linux build failed${NC}"
        return 1
    fi
}

# Build for Windows
build_windows() {
    echo -e "${YELLOW}Building for Windows...${NC}"
    
    $GODOT --headless --export-release "Windows Desktop" "$EXPORT_DIR/windows/norad-war-simulator-$VERSION-windows.zip"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Windows build complete${NC}"
        ls -lh "$EXPORT_DIR/windows/"
    else
        echo -e "${RED}Windows build failed${NC}"
        return 1
    fi
}

# Build for macOS
build_macos() {
    echo -e "${YELLOW}Building for macOS...${NC}"
    
    $GODOT --headless --export-release "macOS" "$EXPORT_DIR/macos/norad-war-simulator-$VERSION-macos.zip"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}macOS build complete${NC}"
        ls -lh "$EXPORT_DIR/macos/"
    else
        echo -e "${RED}macOS build failed${NC}"
        return 1
    fi
}

# Create source package
build_source() {
    echo -e "${YELLOW}Creating source package...${NC}"
    
    local SOURCE_FILE="$EXPORT_DIR/norad-war-simulator-$VERSION-src.tar.gz"
    
    tar --exclude='.git' \
        --exclude='export' \
        --exclude='*.import' \
        --exclude='.godot' \
        --exclude='*.translation' \
        -czf "$SOURCE_FILE" \
        -C "$(dirname "$PROJECT_DIR")" \
        "$(basename "$PROJECT_DIR")"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Source package created${NC}"
        ls -lh "$SOURCE_FILE"
    else
        echo -e "${RED}Source package creation failed${NC}"
        return 1
    fi
}

# Generate checksums
generate_checksums() {
    echo -e "${YELLOW}Generating checksums...${NC}"
    
    cd "$EXPORT_DIR"
    
    find . -type f \( -name "*.tar.gz" -o -name "*.zip" \) -exec sha256sum {} \; > checksums.sha256
    
    echo -e "${GREEN}Checksums generated${NC}"
    cat checksums.sha256
}

# Create release notes
create_release_notes() {
    echo -e "${YELLOW}Creating release notes...${NC}"
    
    local NOTES_FILE="$EXPORT_DIR/RELEASE_NOTES.md"
    
    cat > "$NOTES_FILE" << EOF
# NORAD War Simulator v$VERSION

## Release Notes

### New Features

#### Phase 1-4: Core Game
- Globe-based strategic defense simulation
- Realistic ballistic missile physics
- Satellite early warning system (DSP, SBIRS, GPS-III)
- Multiple interceptor types (GBI, THAAD, Patriot)
- 6 built-in scenarios + custom scenario editor
- 8-mission campaign with tech tree upgrades

#### Phase 5: Polish
- Improved visual effects (multi-stage explosions, contrails)
- Atmospheric audio system
- Button animations and UI polish
- Loading screen with tips

#### Phase 6: Multiplayer
- Co-op mode (team defense)
- Versus mode (competing teams)
- LAN/online multiplayer via ENet
- Lobby system with chat
- State synchronization

#### Phase 7: Steam Integration
- 18 achievements
- Cloud saves
- Workshop support for custom scenarios
- Leaderboards

### System Requirements

#### Minimum
- OS: Windows 10 / Linux (kernel 5.x) / macOS 11
- CPU: Dual-core 2.0 GHz
- RAM: 4 GB
- GPU: OpenGL 3.3 compatible
- Storage: 500 MB

#### Recommended
- OS: Windows 10+ / Linux (kernel 6.x) / macOS 13+
- CPU: Quad-core 3.0 GHz
- RAM: 8 GB
- GPU: OpenGL 4.5 compatible
- Storage: 1 GB

### Known Issues
- Multiplayer requires port 7777 to be open
- Steam features require Steam client running

### Changelog

#### v0.5.0-alpha
- Full multiplayer support (Co-op and Versus)
- Steam Workshop integration
- Leaderboards and achievements
- UI polish and animations

#### v0.4.0-alpha
- Campaign mode with 8 missions
- Tech tree upgrades
- Victory/debriefing screens

#### v0.3.0-alpha
- Scenario editor
- Custom scenarios
- Scenario validation

#### v0.2.0-alpha
- Ballistic physics
- Satellite detection
- Damage model

#### v0.1.0-alpha
- Initial release
- Globe rendering
- Basic missile/interceptor

EOF
    
    echo -e "${GREEN}Release notes created${NC}"
}

# Main build process
main() {
    check_godot
    prepare_export_dir
    
    echo ""
    echo -e "${YELLOW}Starting builds...${NC}"
    echo ""
    
    # Build all platforms
    build_linux
    build_windows
    build_macos
    build_source
    generate_checksums
    create_release_notes
    
    echo ""
    echo -e "${GREEN}=== Build Complete ===${NC}"
    echo ""
    echo "Export directory: $EXPORT_DIR"
    echo ""
    echo "Files:"
    ls -lh "$EXPORT_DIR"
}

# Run
main "$@"