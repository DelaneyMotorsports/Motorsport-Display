/**
 * @file    CanTypes.h
 * @brief   Core data structures for CAN bus communication.
 * @defgroup can_platform CAN Platform Layer
 * @{
 *
 * @details
 * Defines fundamental data types used throughout the Reikon Dash CAN subsystem.
 * The CanFrame structure represents a standard CAN 2.0B frame with 11-bit or 29-bit
 * identifier, up to 8 data bytes, and microsecond-resolution timestamp for precise
 * telemetry correlation and data logging.
 *
 * @section design_philosophy Design Philosophy
 * - Zero-cost abstractions using standard C++ types
 * - Fixed-size data structures for embedded compatibility
 * - Timestamp support for synchronized multi-source telemetry
 * - Compatible with both standard and extended CAN frame formats
 *
 * @section dependencies Dependencies
 * - C++ Standard Library (cstdint, array)
 *
 * @section compiler_requirements Compiler Requirements
 * - g++ 7.0+ (C++17)
 * - clang 5.0+
 *
 * @example
 * @code{.cpp}
 * CanFrame frame;
 * frame.id = 0x100;          // CAN ID (e.g., Engine RPM)
 * frame.dlc = 2;             // Data length: 2 bytes
 * frame.data[0] = 0x12;      // RPM low byte
 * frame.data[1] = 0x34;      // RPM high byte
 * frame.timestamp = 1234567; // Microseconds since epoch
 * @endcode
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#pragma once

#include <cstdint>
#include <array>

/**
 * @struct CanFrame
 * @brief Represents a single CAN 2.0B bus frame.
 *
 * @details
 * CanFrame encapsulates all information from a CAN bus message including identifier,
 * data payload, length, and reception timestamp. Supports both standard (11-bit) and
 * extended (29-bit) CAN identifiers as defined by ISO 11898-1.
 *
 * The structure is designed for zero-copy operation and direct hardware mapping on
 * embedded systems. All fields use fixed-width types for consistent binary layout
 * across platforms.
 *
 * @note This structure does not include CAN FD (Flexible Data-rate) support.
 *       For CAN FD frames with >8 bytes, a separate structure would be required.
 *
 * @see CanBackend
 * @see SignalBus
 */
struct CanFrame
{
    /**
     * @brief CAN identifier (11-bit standard or 29-bit extended).
     *
     * @details
     * - Standard CAN: Uses bits 0-10 (range 0x000-0x7FF)
     * - Extended CAN: Uses bits 0-28 (range 0x00000000-0x1FFFFFFF)
     * - Bit 31: Reserved for IDE (Identifier Extension) flag in some implementations
     */
    uint32_t id;

    /**
     * @brief Data Length Code - number of valid data bytes (0-8).
     *
     * @details
     * Specifies how many bytes in the data array contain valid payload.
     * Must be in range [0, 8] for standard CAN 2.0B.
     *
     * @warning Values >8 are invalid for CAN 2.0B and may cause undefined behavior.
     */
    uint8_t dlc;

    /**
     * @brief Payload data bytes (up to 8 bytes for CAN 2.0B).
     *
     * @details
     * Fixed-size array containing the frame payload. Only the first dlc bytes
     * are valid. Unused bytes should be considered undefined and not relied upon.
     *
     * @note Accessing data beyond dlc index is permitted but produces undefined values.
     */
    std::array<uint8_t, 8> data;

    /**
     * @brief Frame reception timestamp in microseconds.
     *
     * @details
     * Timestamp is typically measured from system boot (monotonic clock) or Unix epoch,
     * depending on implementation. Provides microsecond resolution for accurate
     * telemetry correlation and playback.
     *
     * @note Timestamp source and epoch should be documented at the system level.
     */
    uint64_t timestamp;
};

/** @} */ // end of can_platform group
