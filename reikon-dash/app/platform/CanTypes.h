/**
 * @file    CanTypes.h
 * @brief   Core data structures for CAN bus communication.
 *
 * Defines fundamental data types used throughout the Reikon Dash CAN subsystem.
 * The CanFrame structure represents a standard CAN 2.0B frame with 11-bit or 29-bit
 * identifier, up to 8 data bytes, and microsecond-resolution timestamp for precise
 * telemetry correlation and data logging.
 *
 * Design Philosophy:
 * - Zero-cost abstractions using standard C++ types
 * - Fixed-size data structures for embedded compatibility
 * - Timestamp support for synchronized multi-source telemetry
 * - Compatible with both standard and extended CAN frame formats
 *
 * Dependencies: C++ Standard Library (cstdint, array)
 * Compiler: g++ 7.0+ (C++17), clang 5.0+
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#pragma once

#include <cstdint>
#include <array>

struct CanFrame
{
    uint32_t id;
    uint8_t dlc;
    std::array<uint8_t, 8> data;
    uint64_t timestamp;
};
