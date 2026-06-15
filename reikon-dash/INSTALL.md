# Reikon Dash Installation Guide

**Motorsport Telemetry Display for Raspberry Pi 5**

---

## Quick Start (Raspberry Pi 5)

### One-Line Installation

Transform your Raspberry Pi 5 into a dedicated motorsport head unit with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/pi5-kiosk-hmi/reikon-dash/install.sh | bash
```

**What this does:**
- ✅ Installs all dependencies (Qt 6, build tools, CAN utilities)
- ✅ Builds Reikon Dash with Pi 5 optimizations
- ✅ Configures kiosk mode (fullscreen, auto-start on boot)
- ✅ Sets up virtual CAN interface for testing
- ✅ Disables screen blanking and screensavers
- ✅ Creates systemd service for auto-start
- ✅ Adds user to video/input/render groups for GPU access
- ✅ Automatically detects Raspberry Pi OS or Debian and configures appropriately

After installation completes, reboot your Pi 5:

```bash
sudo reboot
```

Reikon Dash will launch automatically in fullscreen mode!

### Supported Operating Systems

The installer supports both:
- **Raspberry Pi OS 64-bit** (Bookworm or later)
- **Debian 64-bit** (Trixie/13 or later)

The installer automatically detects your OS and configures appropriately.

### Boot Modes

The installer detects your system configuration and chooses the optimal mode:

**Desktop Environment Detected:**
- Installs display manager (lightdm) if needed on Debian
- Boots to graphical.target
- Reikon Dash runs in EGLFS fullscreen

**No Desktop (Console Only):**
- Boots to multi-user.target (console)
- Reikon Dash runs directly via EGLFS from console
- Lighter weight, ideal for dedicated kiosk

Both modes provide identical functionality.

---

## Update Existing Installation

**Safe to run multiple times** - The installer detects existing installations and updates them:

```bash
# Same command as installation
curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/pi5-kiosk-hmi/reikon-dash/install.sh | bash
```

**Update process:**
1. ✅ Detects existing installation
2. ✅ Backs up your custom configs to `/tmp/reikon-dash-backup-TIMESTAMP/`
3. ✅ Updates code (`git pull`)
4. ✅ Rebuilds application
5. ✅ Restores your custom files
6. ✅ Updates systemd service

**Your custom files are always preserved:**
- User configs in `~/.config/reikon-dash/`
- Custom DBC files
- Log history

---

## Manual Installation

If you prefer manual control or need to customize the installation:

### 1. Install Dependencies

```bash
sudo apt update
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
```

### 2. Clone Repository

```bash
git clone https://github.com/DelaneyMotorsports/Motorsport-Display.git
cd Motorsport-Display
git checkout pi5-kiosk-hmi
```

### 3. Build Application

```bash
cd reikon-dash
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j4
```

### 4. Run

```bash
# Fullscreen (default)
./reikon-dash

# Windowed mode (development)
./reikon-dash --windowed

# Specific resolution
./reikon-dash --width 1920 --height 1080

# Help
./reikon-dash --help
```

---

## Display Compatibility

Reikon Dash automatically detects and adapts to your display:

**Supported Resolutions:**
- ✅ **1920x1080** - Full HD (standard HDMI TV)
- ✅ **3840x2160** - 4K Ultra HD
- ✅ **1920x720** - Ultra-wide automotive display
- ✅ **1280x720** - HD Ready
- ✅ **Any resolution** - Auto-detected!

**Display Modes:**
- **Fullscreen** (default) - Perfect for kiosk deployment
- **Windowed** - For development and testing

---

## Configuration

### Systemd Service

Edit the service file to customize startup:

```bash
sudo nano /etc/systemd/system/reikon-dash.service
```

**Restart after changes:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart reikon-dash
```

### Display Resolution Override

Pass custom resolution via command-line:

```bash
# Edit service file
sudo nano /etc/systemd/system/reikon-dash.service

# Change ExecStart line:
ExecStart=/home/pi/Motorsport-Display/reikon-dash/build/reikon-dash --width 1920 --height 1080
```

### Enable/Disable Auto-Start

```bash
# Disable auto-start on boot
sudo systemctl disable reikon-dash

# Enable auto-start on boot
sudo systemctl enable reikon-dash
```

---

## Usage

### Command-Line Options

```bash
./reikon-dash [OPTIONS]

Options:
  --fullscreen, -f        Run in fullscreen mode (default)
  --windowed              Run in windowed mode
  --width, -w <pixels>    Set window width
  --height, -h <pixels>   Set window height
  --help                  Show help message
  --version               Show version information
```

### Examples

```bash
# Default - Fullscreen with auto-detected resolution
./reikon-dash

# 1080p HDMI TV
./reikon-dash --width 1920 --height 1080

# 4K display
./reikon-dash --width 3840 --height 2160

# Development mode (windowed)
./reikon-dash --windowed --width 1280 --height 720
```

### Screen Navigation

**Keyboard Controls:**
- **Right Arrow** / **PageDown** - Next screen
- **Left Arrow** / **PageUp** - Previous screen
- **1** - Jump to Screen 1 (Main Dashboard)
- **2** - Jump to Screen 2 (Minimal Racing View)
- **3** - Jump to Screen 3 (Data-Heavy View)
- **Escape** / **Alt+F4** - Exit (windowed mode only)

**Touch Controls:**
- **Swipe Left** - Next screen
- **Swipe Right** - Previous screen

---

## Troubleshooting

### View Logs

```bash
# Follow live logs
journalctl -u reikon-dash -f

# View recent logs
journalctl -u reikon-dash -n 100

# View logs since boot
journalctl -u reikon-dash -b
```

### Restart Service

```bash
sudo systemctl restart reikon-dash
```

### Check Service Status

```bash
sudo systemctl status reikon-dash
```

### Test Without Kiosk Mode

```bash
# Stop service
sudo systemctl stop reikon-dash

# Run manually
cd ~/Motorsport-Display/reikon-dash/build
./reikon-dash --windowed
```

### Service Not Starting After Reboot

If the service shows "inactive (dead)" after reboot:

**1. Check boot target:**
```bash
systemctl get-default
```

**2. Check service configuration:**
```bash
grep "WantedBy=" /etc/systemd/system/reikon-dash.service
```

**Expected configurations:**
- If boot target is `multi-user.target` (console mode): Service should show `WantedBy=multi-user.target`
- If boot target is `graphical.target` (desktop mode): Service should show `WantedBy=graphical.target`

**3. If mismatch detected:**
Re-run the installer to reconfigure:
```bash
curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/pi5-kiosk-hmi/reikon-dash/install.sh | bash
sudo reboot
```

**4. Check logs for errors:**
```bash
journalctl -u reikon-dash -n 50 --no-pager
```

### Debian-Specific Issues

**Permission denied errors:**
Verify user is in video/input groups:
```bash
sudo usermod -a -G video,input $USER
# Reboot after adding groups
sudo reboot
```

**EGLFS not available:**
Install OpenGL ES libraries:
```bash
sudo apt install libgles2-mesa libgles2-mesa-dev
```

**Auto-login not working:**
Check systemd override:
```bash
cat /etc/systemd/system/getty@tty1.service.d/autologin.conf
# Should contain ExecStart with --autologin
```

### Display Issues

**Black screen or wrong resolution:**
```bash
# Check detected resolution
./reikon-dash --help
# (shows detected display info)

# Force specific resolution
./reikon-dash --width 1920 --height 1080
```

**Update service with correct resolution:**
```bash
sudo nano /etc/systemd/system/reikon-dash.service
# Edit ExecStart line
sudo systemctl daemon-reload
sudo systemctl restart reikon-dash
```

### Build Errors

**Qt 6 not found:**
```bash
# Reinstall Qt 6 dependencies
sudo apt install --reinstall qt6-base-dev qt6-declarative-dev
```

**CMake errors:**
```bash
# Clean and rebuild
cd ~/Motorsport-Display/reikon-dash
rm -rf build
mkdir build && cd build
cmake ..
cmake --build . -j4
```

---

## Uninstall

### Remove Service

```bash
sudo systemctl stop reikon-dash
sudo systemctl disable reikon-dash
sudo rm /etc/systemd/system/reikon-dash.service
sudo systemctl daemon-reload
```

### Remove Application

```bash
rm -rf ~/Motorsport-Display
```

### Remove Dependencies (Optional)

```bash
sudo apt remove qt6-base-dev qt6-declarative-dev qml6-module-*
sudo apt autoremove
```

### Keep Custom Configs

Your custom files remain in:
- `~/.config/reikon-dash/`
- Backups in `/tmp/reikon-dash-backup-*/`

---

## Advanced Configuration

### Read-Only Filesystem (Production)

For increased reliability in racing environments:

```bash
# Enable read-only root filesystem
sudo raspi-config
# Advanced Options → Overlay File System → Enable

# Logs will be stored in RAM
```

### Custom CAN Interface

Edit service to use real CAN hardware:

```bash
sudo nano /etc/systemd/system/reikon-dash.service

# Add environment variable:
Environment="CAN_INTERFACE=can0"
```

### Performance Tuning

```bash
# Edit service file
sudo nano /etc/systemd/system/reikon-dash.service

# Add performance options:
Environment="QT_QPA_EGLFS_KMS_ATOMIC=1"
Environment="QT_QUICK_CONTROLS_STYLE=Basic"
```

---

## Support

**Documentation:** See [docs/pi5_testing.md](docs/pi5_testing.md) for detailed testing procedures

**Issues:** Report bugs at https://github.com/DelaneyMotorsports/Motorsport-Display/issues

**Company:** Delaney Motorsports, LLC  
**Location:** Sarasota, FL  
**Author:** Kevin Delaney

---

## License

See [LICENSE](../LICENSE) file in repository root.
