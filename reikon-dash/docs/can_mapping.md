# CAN Signal Mapping

## Overview

This document describes the CAN bus signal mappings used in Reikon Dash.

## Signal List

### Engine Data (0x100-0x1FF)

| Signal Name | CAN ID | Start Bit | Length | Scale | Offset | Unit |
|-------------|--------|-----------|--------|-------|--------|------|
| EngineRPM   | 0x100  | 0         | 16     | 1     | 0      | rpm  |
| ThrottlePos | 0x101  | 0         | 8      | 0.5   | 0      | %    |
| CoolantTemp | 0x102  | 0         | 8      | 1     | -40    | °C   |

### Vehicle Data (0x200-0x2FF)

| Signal Name | CAN ID | Start Bit | Length | Scale | Offset | Unit |
|-------------|--------|-----------|--------|-------|--------|------|
| VehicleSpeed| 0x200  | 0         | 16     | 0.01  | 0      | km/h |
| BrakePressure| 0x201 | 0         | 16     | 0.1   | 0      | bar  |

### Transmission Data (0x300-0x3FF)

| Signal Name | CAN ID | Start Bit | Length | Scale | Offset | Unit |
|-------------|--------|-----------|--------|-------|--------|------|
| Gear        | 0x300  | 0         | 4      | 1     | 0      | -    |
| ClutchPos   | 0x301  | 0         | 8      | 0.5   | 0      | %    |

## Notes

- All CAN IDs use standard 11-bit identifiers
- Byte order: Little-endian
- Update rate: 10-100 Hz depending on signal criticality
