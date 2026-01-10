# Reikon Dash Architecture

## Overview

Reikon Dash is a Qt/QML-based motorsport display application designed to run on embedded hardware and visualize real-time telemetry data from CAN bus systems.

## Architecture Layers

### 1. Platform Layer (`app/platform/`)
- **CanBackend**: Abstract interface for CAN communication
- **CanTypes**: Common CAN data structures
- Platform-specific implementations for different hardware

### 2. Model Layer (`app/model/`)
- **SignalBus**: Central signal repository and distribution
- **Dbc/**: DBC file parsing and signal decoding (optional)

### 3. Services Layer (`app/services/`)
- **Logger**: Application logging and diagnostics
- Additional services as needed

### 4. Presentation Layer (`qml/`)
- **App.qml**: Main application window
- **screens/**: Dashboard screen layouts (Qt Design Studio compatible)
- **components/**: Reusable QML components

## Data Flow

1. CAN frames received by CanBackend
2. Frames decoded into signals via DBC definitions
3. Signals published to SignalBus
4. QML components subscribe to SignalBus for updates
5. UI updates in real-time

## Build System

CMake-based build with Qt 6 integration.
