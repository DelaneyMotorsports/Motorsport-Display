# Reikon Dash

A high-performance motorsport dashboard application built with Qt/QML, designed to display real-time telemetry data from CAN bus systems on embedded hardware.

## Features

- **Real-time CAN bus integration** - Direct communication with vehicle CAN networks
- **Customizable dashboard layouts** - Multiple screen configurations for different use cases
- **Qt Design Studio compatible** - Visual design workflow for rapid UI development
- **Modular architecture** - Clean separation of platform, model, and presentation layers
- **Cross-platform support** - Runs on Linux embedded systems and desktop platforms
- **Signal-based architecture** - Flexible data distribution via SignalBus
- **Comprehensive logging** - Built-in diagnostic and debugging capabilities

## Requirements

### Runtime
- Qt 6.x (Core, Quick modules)
- Linux with SocketCAN support (for CAN communication)
- OpenGL ES 2.0+ compatible graphics

### Development
- CMake 3.16 or higher
- C++17 compatible compiler (GCC 7+, Clang 5+)
- Qt 6 development packages
- Qt Design Studio (optional, for UI editing)

### CAN Tools (optional, for testing)
- `can-utils` package for SocketCAN utilities
- Virtual CAN (vcan) kernel module for testing without hardware

## Installation

### 1. Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install qt6-base-dev qt6-declarative-dev cmake build-essential
sudo apt-get install can-utils  # Optional: for CAN testing
```

**Arch Linux:**
```bash
sudo pacman -S qt6-base qt6-declarative cmake gcc
sudo pacman -S can-utils  # Optional: for CAN testing
```

### 2. Clone the Repository

```bash
git clone https://github.com/DelaneyMotorsports/Motorsport-Display.git
cd Motorsport-Display/reikon-dash
```

## Building

### Standard Build

```bash
mkdir build
cd build
cmake ..
cmake --build .
```

### Release Build

```bash
mkdir build-release
cd build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

### Cross-compilation (for embedded targets)

```bash
mkdir build-arm
cd build-arm
cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/toolchain.cmake ..
cmake --build .
```

## Running

### Desktop (with virtual CAN)

1. Set up virtual CAN interface:
```bash
cd tools/can
sudo ./vcan_setup.sh
```

2. Run the application:
```bash
./build/reikon-dash
```

3. (Optional) Replay CAN data:
```bash
cd tools/can
./replay_log.sh your_log_file.log vcan0
```

### Embedded Target

Deploy the built binary to your target device and run:
```bash
./reikon-dash
```

## Project Structure

```
reikon-dash/
├── CMakeLists.txt           # Build configuration
├── README.md                # This file
├── .gitignore              # Git ignore rules
├── app/                    # Application source code
│   ├── main.cpp            # Application entry point
│   ├── platform/           # Platform abstraction layer
│   │   ├── CanBackend.h    # CAN backend interface
│   │   ├── CanBackend.cpp  # CAN backend implementation
│   │   └── CanTypes.h      # CAN data structures
│   ├── model/              # Data model layer
│   │   ├── SignalBus.h     # Signal distribution system
│   │   ├── SignalBus.cpp   # SignalBus implementation
│   │   └── Dbc/            # DBC file support (future)
│   └── services/           # Application services
│       ├── Logger.h        # Logging service
│       └── Logger.cpp      # Logger implementation
├── qml/                    # QML UI files
│   ├── App.qml             # Main application window
│   ├── screens/            # Dashboard screen layouts
│   │   └── Screen01.ui.qml # Example screen (Design Studio)
│   └── components/         # Reusable UI components
│       ├── GaugeArc.qml    # Arc-style gauge
│       └── ShiftLight.qml  # Shift indicator light
├── assets/                 # Static resources
│   ├── fonts/              # Custom fonts
│   └── images/             # Images and icons
├── tools/                  # Development and testing tools
│   └── can/                # CAN-related utilities
│       ├── vcan_setup.sh   # Virtual CAN setup script
│       └── replay_log.sh   # CAN log replay script
└── docs/                   # Documentation
    ├── architecture.md     # Architecture overview
    └── can_mapping.md      # CAN signal mappings
```

## Development

### Architecture Overview

Reikon Dash follows a layered architecture:

1. **Platform Layer** - Hardware abstraction for CAN communication
2. **Model Layer** - Signal processing and data distribution
3. **Services Layer** - Cross-cutting concerns (logging, etc.)
4. **Presentation Layer** - QML-based UI components

See [docs/architecture.md](docs/architecture.md) for detailed information.

### CAN Signal Mapping

CAN signals are mapped through the SignalBus system. See [docs/can_mapping.md](docs/can_mapping.md) for signal definitions and DBC information.

### Adding New Screens

1. Create a new `.ui.qml` file in `qml/screens/`
2. Design the layout in Qt Design Studio or manually
3. Reference the screen in `App.qml`

### Creating Custom Components

1. Add new QML components to `qml/components/`
2. Use SignalBus to bind to real-time data
3. Follow the existing component patterns for consistency

### Testing with Virtual CAN

```bash
# Terminal 1: Setup vcan and start candump
sudo ./tools/can/vcan_setup.sh
candump vcan0

# Terminal 2: Run the application
./build/reikon-dash

# Terminal 3: Send test CAN frames
cansend vcan0 100#1122334455667788
```

## Configuration

Configuration options can be added to handle:
- CAN interface selection
- Screen resolution and orientation
- Signal mappings and scaling
- Theme customization

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

See [LICENSE](../LICENSE) file for details.

## Support

For issues, questions, or contributions, please visit:
- GitHub Issues: https://github.com/DelaneyMotorsports/Motorsport-Display/issues
- Project Wiki: https://github.com/DelaneyMotorsports/Motorsport-Display/wiki

## Roadmap

- [ ] DBC file parsing and automatic signal decoding
- [ ] Multiple screen/layout support with runtime switching
- [ ] Data logging and replay functionality
- [ ] Configuration file support
- [ ] Performance optimization for resource-constrained devices
- [ ] Additional gauge and visualization components
- [ ] WiFi/network telemetry streaming
- [ ] Touch screen input support

---

Built with ❤️ for motorsport enthusiasts
