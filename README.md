# Motorsport-Display

A motorsport dashboard application built with Qt/QML for displaying real-time CAN bus telemetry data on embedded hardware.

---

## 📊 Project Status

**Overall Completion: 32%** - Early Development Phase

This project is in active development. Core architecture is complete, but many features are planned or in progress.

| Component | Status | Completion |
|-----------|--------|------------|
| **Core Architecture** | ✅ Complete | 100% |
| **CAN Platform Layer** | ✅ Complete | 100% |
| **Signal Bus (Model Layer)** | ✅ Complete | 100% |
| **Logging Services** | ✅ Complete | 100% |
| **QML UI Framework** | 🟡 In Progress | 40% |
| **CAN Decoder/DBC Support** | 🔴 Planned | 0% |
| **Data Logging** | 🔴 Planned | 0% |
| **Configuration System** | 🔴 Planned | 0% |
| **Testing & Validation** | 🟡 In Progress | 25% |
| **Documentation** | ✅ Complete | 100% |

---

## 🚀 Raspberry Pi 5 Installation

### Quick Start - One-Line Install

Transform your Raspberry Pi 5 into a dedicated motorsport head unit with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/pi5-kiosk-hmi/reikon-dash/install.sh | bash
```

After installation completes, reboot your Pi:
```bash
sudo reboot
```

Reikon Dash will auto-start in fullscreen kiosk mode! 🏁

### Recommended Base OS

**Option 1: Raspberry Pi OS 64-bit** (Bookworm or later)
- ✅ **Pi OS 64-bit Desktop** - Full desktop environment (recommended for development)
- ✅ **Pi OS 64-bit Lite** - Minimal install (recommended for production kiosk)

**Option 2: Debian 64-bit** (Trixie/13 or later)
- ✅ **Debian with Desktop** - Full desktop environment
- ✅ **Debian Minimal** - Console-only (lightest weight)

**Downloads:**
- **Raspberry Pi OS:** https://www.raspberrypi.com/software/operating-systems/
- **Debian:** https://www.debian.org/download

The installer automatically detects and configures for your OS.

### What Gets Installed

The one-line installer automatically:
- ✅ Installs Qt 6 and all dependencies
- ✅ Builds Reikon Dash optimized for Pi 5
- ✅ Configures fullscreen kiosk mode
- ✅ Sets up auto-start on boot
- ✅ Detects and adapts to your display (1080p, 4K, any resolution)
- ✅ Detects OS (Raspberry Pi OS or Debian) and configures appropriately
- ✅ Creates systemd service with auto-restart
- ✅ Sets up virtual CAN interface for testing

### Display Compatibility

Automatically adapts to any HDMI display:
- **1920x1080** (Full HD) - Standard HDMI TV
- **3840x2160** (4K Ultra HD)
- **1920x720** (Ultra-wide automotive)
- Any other resolution - Auto-detected!

### Update/Repair Existing Installation

Safe to run multiple times - automatically detects and updates existing installations while preserving your custom configurations:

```bash
# Same command updates existing installation
curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/pi5-kiosk-hmi/reikon-dash/install.sh | bash
sudo systemctl restart reikon-dash
```

### Manual Installation & Documentation

For development or custom setups, see **[INSTALL.md](reikon-dash/INSTALL.md)** for:
- Manual installation steps
- Configuration options
- Troubleshooting
- Advanced setup

---

## 🎯 Development Goals

This project is being developed with automotive software quality standards in mind:

- **MISRA C++:2023** - Software reliability guidelines (in progress)
- **AUTOSAR C++14** - Modern C++ automotive practices (in progress)
- **SEI CERT C/C++** - Secure coding standards (in progress)
- **Doxygen documentation** - Professional API reference

Future goals include ISO 26262 functional safety and ISO/SAE 21434 cybersecurity compliance.

---

## 💻 Development & Manual Build

### For Raspberry Pi 5 (Production)

**Use the one-line installer** (see [Installation section](#-raspberry-pi-5-installation) above):
```bash
curl -sSL https://raw.githubusercontent.com/DelaneyMotorsports/Motorsport-Display/pi5-kiosk-hmi/reikon-dash/install.sh | bash
```

### For Development (Desktop/Manual Build)

All development happens in the `reikon-dash/` subdirectory:

```bash
cd reikon-dash
```

See **[reikon-dash/README.md](reikon-dash/README.md)** for:
- Installation and build instructions
- Feature documentation
- Architecture overview
- Development guidelines

### Quick Build

```bash
cd reikon-dash
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j$(nproc)
./reikon-dash
```

---

## 📂 Repository Structure

```
Motorsport-Display/
├── LICENSE                    # AGPL-3.0 license
├── README.md                  # This file
│
└── reikon-dash/               # Main application
    ├── README.md              # Detailed documentation
    ├── CMakeLists.txt         # Build configuration
    ├── Doxyfile               # API documentation config
    │
    ├── app/                   # C++ application source
    │   ├── main.cpp           # Entry point
    │   ├── platform/          # CAN abstraction
    │   ├── model/             # Signal distribution
    │   └── services/          # Logging
    │
    ├── qml/                   # Qt/QML user interface
    │   ├── App.qml            # Main window
    │   ├── screens/           # Dashboard layouts
    │   └── components/        # Gauges, shift lights
    │
    ├── tools/                 # Development utilities
    │   └── can/               # Virtual CAN setup scripts
    │
    └── docs/                  # Documentation
        ├── architecture.md    # System design
        ├── can_mapping.md     # CAN signal definitions
        ├── coding_standards.md # Development guidelines
        └── doxygen/           # Generated API docs
```

---

## ✨ Features

### Implemented
- Modular architecture with clean separation of concerns
- CAN bus platform abstraction layer
- Signal distribution system (SignalBus)
- Diagnostic logging service
- Basic QML UI framework
- Qt Design Studio compatible

### In Progress
- QML dashboard components (gauges, displays)
- Unit testing framework

### Planned
- DBC file parsing for automatic signal decoding
- Data logging and replay functionality
- Configuration file support
- Multi-screen layouts
- WiFi telemetry streaming
- Touch screen input support

---

## 📖 Documentation

### For Users
- **[Getting Started](reikon-dash/README.md)** - Installation and usage
- **[CAN Signal Reference](reikon-dash/docs/can_mapping.md)** - Signal definitions

### For Developers
- **[Architecture Guide](reikon-dash/docs/architecture.md)** - System design
- **[Coding Standards](reikon-dash/docs/coding_standards.md)** - Development guidelines
- **[API Reference](reikon-dash/docs/doxygen/html/index.html)** - Generated from source

### Generate Documentation

```bash
cd reikon-dash
doxygen Doxyfile
xdg-open docs/doxygen/html/index.html
```

---

## 🛠️ Development

### Requirements

**Runtime:**
- Linux with SocketCAN support
- Qt 6.x (Core, Quick, Qml modules)
- OpenGL ES 2.0+

**Build Tools:**
- CMake 3.16+
- GCC 7+ or Clang 5+ (C++17 support)
- Qt 6 development packages

**Optional:**
- Doxygen and Graphviz (for documentation)
- Cppcheck and Clang-Tidy (for static analysis)
- can-utils (for CAN testing)

### Build

```bash
cd reikon-dash

# Debug build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build .

# Release build
mkdir build-release && cd build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

---

## 🧪 Testing

### Virtual CAN Setup

```bash
cd reikon-dash/tools/can
sudo ./vcan_setup.sh

# Send test frames
cansend vcan0 100#0011223344556677
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Read the coding standards in [reikon-dash/docs/coding_standards.md](reikon-dash/docs/coding_standards.md)
2. Ensure code follows the project's C++ guidelines
3. Add/update documentation for new features
4. Test changes thoroughly before submitting

**Process:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [reikon-dash/README.md](reikon-dash/README.md) for detailed guidelines.

---

## 📜 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

See [LICENSE](LICENSE) file for details.

---

## 🆘 Support

- **GitHub Issues**: https://github.com/DelaneyMotorsports/Motorsport-Display/issues
- **Discussions**: https://github.com/DelaneyMotorsports/Motorsport-Display/discussions

---

## 🗺️ Roadmap

### Current Phase - Foundation (32% Complete)
- [x] Core architecture
- [x] CAN platform layer
- [x] Signal distribution system
- [x] Basic UI framework
- [ ] DBC parser
- [ ] Data logging
- [ ] Unit tests

### Future Development
- Multi-screen support
- Configuration system
- Advanced UI components
- Network telemetry
- Touch input support

**Note:** This is an early-stage project under active development. Features and timelines are subject to change.

---

## 👨‍💻 About

**Author**: Kevin Delaney
**Company**: Delaney Motorsports, LLC
**Location**: Sarasota, Florida

This project aims to provide a high-quality, open-source telemetry display system for motorsport applications.

---

**For complete documentation, see [reikon-dash/README.md](reikon-dash/README.md)**
