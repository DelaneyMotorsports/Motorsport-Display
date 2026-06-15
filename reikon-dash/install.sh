#!/bin/bash
#
# Reikon Dash Pi5 Kiosk Installation Script
# Idempotent installer - safe to run multiple times for updates/repairs
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/claude/verify-dev-branch-Cax2D/reikon-dash/install.sh | bash
#
# Or download and run:
#   wget https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/claude/verify-dev-branch-Cax2D/reikon-dash/install.sh
#   chmod +x install.sh
#   ./install.sh
#
# @author  Kevin Delaney
# @date    January 14, 2026
# @company Delaney Motorsports, LLC
# @address Sarasota, FL

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/DelaneyMotorsports/Motorsport-Display.git"
BRANCH="claude/verify-dev-branch-Cax2D"
INSTALL_DIR="$HOME/Motorsport-Display"
APP_DIR="$INSTALL_DIR/reikon-dash"
BUILD_DIR="$APP_DIR/build"

# Global variables
EXISTING_INSTALL=false
BACKUP_DIR=""

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Print banner
print_banner() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║            Reikon Dash Pi5 Kiosk Installer                ║"
    echo "║        Motorsport Telemetry Head Unit for Pi 5            ║"
    echo "║                                                            ║"
    echo "║              Delaney Motorsports, LLC                     ║"
    echo "║                   Sarasota, FL                            ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# Detect existing installation
detect_existing_installation() {
    log_step "Checking for existing installation..."

    if [ -d "$INSTALL_DIR" ] && [ -f "$BUILD_DIR/reikon-dash" ]; then
        log_info "Existing installation detected - will update"
        EXISTING_INSTALL=true
    else
        log_info "Fresh installation"
        EXISTING_INSTALL=false
    fi
}

# Backup custom files before update
backup_custom_files() {
    if [ "$EXISTING_INSTALL" = true ]; then
        BACKUP_DIR="/tmp/reikon-dash-backup-$(date +%Y%m%d-%H%M%S)"
        log_step "Backing up custom files to $BACKUP_DIR"

        mkdir -p "$BACKUP_DIR"

        # Backup user configs
        if [ -d "$HOME/.config/reikon-dash" ]; then
            cp -r "$HOME/.config/reikon-dash" "$BACKUP_DIR/"
            log_info "Backed up user configs"
        fi

        # Backup custom DBC files
        if [ -d "$APP_DIR/config/dbc" ]; then
            cp -r "$APP_DIR/config/dbc" "$BACKUP_DIR/"
            log_info "Backed up custom DBC files"
        fi

        # Backup logs
        if [ -d "/var/log/reikon-dash" ]; then
            sudo cp -r /var/log/reikon-dash "$BACKUP_DIR/"
            log_info "Backed up log files"
        fi

        log_info "Backup complete: $BACKUP_DIR"
    fi
}

# Restore custom files after update
restore_custom_files() {
    if [ "$EXISTING_INSTALL" = true ] && [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        log_step "Restoring custom files from backup..."

        # Restore user configs
        if [ -d "$BACKUP_DIR/reikon-dash" ]; then
            mkdir -p "$HOME/.config"
            cp -r "$BACKUP_DIR/reikon-dash" "$HOME/.config/"
            log_info "Restored user configs"
        fi

        # Restore custom DBC files
        if [ -d "$BACKUP_DIR/dbc" ]; then
            mkdir -p "$APP_DIR/config"
            cp -r "$BACKUP_DIR/dbc" "$APP_DIR/config/"
            log_info "Restored custom DBC files"
        fi

        # Restore logs
        if [ -d "$BACKUP_DIR/reikon-dash" ] && [ "$(ls -A $BACKUP_DIR/reikon-dash 2>/dev/null)" ]; then
            sudo mkdir -p /var/log
            sudo cp -r "$BACKUP_DIR/reikon-dash" /var/log/
            log_info "Restored log files"
        fi

        log_info "Custom files restored"
        log_info "Backup kept at: $BACKUP_DIR (safe to delete manually)"
    fi
}

# Hardware detection
detect_hardware() {
    log_step "Detecting hardware..."

    if grep -q "Raspberry Pi 5" /proc/cpuinfo; then
        log_info "Raspberry Pi 5 detected ✓"
    else
        log_warn "Not running on Raspberry Pi 5 - performance may vary"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled"
        fi
    fi
}

# Install dependencies
install_dependencies() {
    log_step "Installing Qt 6 and dependencies..."

    log_info "Updating package lists..."
    sudo apt update

    log_info "Installing packages (this may take a few minutes)..."
    sudo apt install -y \
        qt6-base-dev \
        qt6-declarative-dev \
        qml6-module-qtquick \
        qml6-module-qtquick-window \
        qml6-module-qtquick-controls \
        qml6-module-qtquick-layouts \
        qml6-module-qtquick-shapes \
        cmake \
        build-essential \
        git \
        can-utils \
        python3-can

    log_info "Dependencies installed ✓"
}

# Clone/update repository
setup_repository() {
    log_step "Setting up repository..."

    if [ ! -d "$INSTALL_DIR" ]; then
        log_info "Cloning Reikon Dash repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
        git checkout "$BRANCH"
        log_info "Repository cloned ✓"
    else
        log_info "Updating Reikon Dash repository..."
        cd "$INSTALL_DIR"
        git fetch origin
        git checkout "$BRANCH"
        git pull origin "$BRANCH"
        log_info "Repository updated ✓"
    fi
}

# Build application
build_application() {
    log_step "Building Reikon Dash..."

    cd "$APP_DIR"

    # Clean build directory
    if [ -d "$BUILD_DIR" ]; then
        log_info "Cleaning previous build..."
        rm -rf "$BUILD_DIR"
    fi

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    log_info "Configuring build..."
    cmake -DCMAKE_BUILD_TYPE=Release ..

    log_info "Compiling (this may take a few minutes)..."
    cmake --build . -j4

    if [ -f "$BUILD_DIR/reikon-dash" ]; then
        log_info "Build successful ✓"
    else
        log_error "Build failed - reikon-dash binary not found"
    fi
}

# Configure kiosk mode
configure_kiosk() {
    log_step "Configuring kiosk mode..."

    # Detect OS type
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME="$NAME"
        log_info "Detected OS: $OS_NAME"
    fi

    # Detect if desktop environment is installed
    if dpkg -l 2>/dev/null | grep -qE "xserver-xorg|wayland|lxde|xfce|gnome|desktop"; then
        HAS_DESKTOP=true
        log_info "Desktop environment detected"
    else
        HAS_DESKTOP=false
        log_info "No desktop environment detected - configuring console mode"
    fi

    # Configure auto-login based on OS
    if [[ "$OS_NAME" == *"Raspberry Pi"* ]]; then
        # Raspberry Pi OS - use raspi-config
        if ! grep -q "autologin" /etc/systemd/system/getty.target.wants/getty@tty1.service 2>/dev/null; then
            log_info "Enabling auto-login (Pi OS)..."
            sudo raspi-config nonint do_boot_behaviour B2 2>/dev/null || true
        fi
    else
        # Debian or other - configure manually
        log_info "Enabling auto-login (Debian)..."

        # Create autologin override for getty@tty1
        sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
        sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
    fi

    # Disable screen blanking (support both boot locations)
    if ! grep -q "consoleblank=0" /boot/cmdline.txt 2>/dev/null && ! grep -q "consoleblank=0" /boot/firmware/cmdline.txt 2>/dev/null; then
        log_info "Disabling screen blanking..."
        if [ -f /boot/firmware/cmdline.txt ]; then
            sudo sed -i 's/$/ consoleblank=0/' /boot/firmware/cmdline.txt
        elif [ -f /boot/cmdline.txt ]; then
            sudo sed -i 's/$/ consoleblank=0/' /boot/cmdline.txt
        fi
    fi

    # Create EGLFS KMS configuration for better display compatibility
    log_info "Creating EGLFS KMS configuration..."
    sudo tee /etc/reikon-dash-kms.json > /dev/null <<'EOFKMS'
{
  "device": "/dev/dri/card1",
  "hwcursor": false,
  "pbuffers": true,
  "separateScreens": false
}
EOFKMS

    # Determine boot mode and service configuration
    if [ "$HAS_DESKTOP" = true ]; then
        log_info "Configuring for graphical boot mode..."

        # Install display manager if not present (Debian only)
        if [[ "$OS_NAME" != *"Raspberry Pi"* ]]; then
            if ! systemctl list-unit-files 2>/dev/null | grep -qE "lightdm|gdm|sddm"; then
                log_info "Installing lightdm display manager..."
                sudo apt install -y lightdm
            fi
        fi

        # Enable graphical target
        sudo systemctl set-default graphical.target 2>/dev/null || true

        # Create systemd service (graphical mode)
        log_info "Creating systemd service (graphical mode)..."
        sudo tee /etc/systemd/system/reikon-dash.service > /dev/null <<EOF
[Unit]
Description=Reikon Dash Motorsport Head Unit
After=graphical.target network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$BUILD_DIR
Environment="QT_QPA_PLATFORM=eglfs"
Environment="QSG_RENDER_LOOP=basic"
Environment="QT_QPA_EGLFS_KMS_CONFIG=/etc/reikon-dash-kms.json"
ExecStart=$BUILD_DIR/reikon-dash --fullscreen
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical.target
EOF
    else
        log_info "Configuring for console boot mode (no desktop)..."

        # Create systemd service (console mode with EGLFS)
        log_info "Creating systemd service (console mode)..."
        sudo tee /etc/systemd/system/reikon-dash.service > /dev/null <<EOF
[Unit]
Description=Reikon Dash Motorsport Head Unit
After=multi-user.target network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$BUILD_DIR
Environment="QT_QPA_PLATFORM=eglfs"
Environment="QSG_RENDER_LOOP=basic"
Environment="QT_QPA_EGLFS_KMS_CONFIG=/etc/reikon-dash-kms.json"
ExecStart=$BUILD_DIR/reikon-dash --fullscreen
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    fi

    sudo systemctl daemon-reload
    sudo systemctl enable reikon-dash.service

    log_info "Kiosk mode configured ✓"
}

# Configure user permissions for EGLFS
configure_permissions() {
    log_step "Configuring user permissions for EGLFS..."

    # Add user to video, input, and render groups for GPU/display access
    GROUPS_NEEDED="video input render"
    GROUPS_ADDED=""

    for group in $GROUPS_NEEDED; do
        if getent group $group > /dev/null 2>&1; then
            if ! groups $USER | grep -q "\b$group\b"; then
                sudo usermod -a -G $group $USER
                GROUPS_ADDED="$GROUPS_ADDED $group"
                log_info "Added $USER to $group group"
            fi
        fi
    done

    if [ -n "$GROUPS_ADDED" ]; then
        log_warn "User added to groups:$GROUPS_ADDED"
        log_warn "You may need to log out and back in for group changes to take effect"
    else
        log_info "User already has required group memberships"
    fi

    log_info "Permissions configured ✓"
}

# Setup CAN interface
setup_can() {
    log_step "Setting up CAN interface..."

    # Create vcan0 setup script
    log_info "Creating vcan setup script..."
    sudo tee /usr/local/bin/vcan-setup.sh > /dev/null <<'EOF'
#!/bin/bash
modprobe vcan
ip link add dev vcan0 type vcan 2>/dev/null || true
ip link set up vcan0
EOF
    sudo chmod +x /usr/local/bin/vcan-setup.sh

    # Auto-load vcan on boot
    log_info "Creating vcan systemd service..."
    sudo tee /etc/systemd/system/vcan-setup.service > /dev/null <<EOF
[Unit]
Description=Virtual CAN Interface Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vcan-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable vcan-setup.service

    # Setup vcan now
    sudo /usr/local/bin/vcan-setup.sh 2>/dev/null || true

    log_info "CAN interface configured ✓"
}

# Main installation flow
main() {
    print_banner

    log_info "Starting Reikon Dash Pi5 Kiosk Installation..."
    echo ""

    # Detect if this is an update or fresh install
    detect_existing_installation

    # Backup custom files before making changes (update only)
    backup_custom_files

    detect_hardware
    install_dependencies
    setup_repository
    build_application

    # Restore custom files after rebuild (update only)
    restore_custom_files

    configure_kiosk
    configure_permissions
    setup_can

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    if [ "$EXISTING_INSTALL" = true ]; then
        echo "║                   Update Complete! ✓                      ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        log_info "Reikon Dash has been updated to the latest version"
        log_info "Custom files preserved and restored"
        if [ -n "$BACKUP_DIR" ]; then
            log_info "Backup location: $BACKUP_DIR"
        fi
    else
        echo "║                Installation Complete! ✓                   ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        log_info "Reikon Dash is configured to start on boot"
    fi

    echo ""
    echo "Next steps:"
    echo "  ${BLUE}1.${NC} Restart service:  ${GREEN}sudo systemctl restart reikon-dash${NC}"
    echo "  ${BLUE}2.${NC} Or reboot Pi:     ${GREEN}sudo reboot${NC}"
    echo ""
    echo "View logs:"
    echo "  ${GREEN}journalctl -u reikon-dash -f${NC}"
    echo ""
    echo "Run in windowed mode (development):"
    echo "  ${GREEN}$BUILD_DIR/reikon-dash --windowed${NC}"
    echo ""
    echo "Command-line options:"
    echo "  ${GREEN}$BUILD_DIR/reikon-dash --help${NC}"
    echo ""
}

# Run main function
main "$@"
