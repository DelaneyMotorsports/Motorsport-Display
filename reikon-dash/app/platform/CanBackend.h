/**
 * @file    CanBackend.h
 * @brief   Abstract interface for CAN bus communication backend.
 * @ingroup can_platform
 *
 * @details
 * CanBackend provides a platform-abstraction layer for CAN bus operations, allowing
 * the Reikon Dash application to communicate with vehicle CAN networks through various
 * hardware interfaces (SocketCAN on Linux, hardware-specific drivers, etc.). The class
 * uses Qt's signal/slot mechanism to deliver received CAN frames asynchronously to the
 * application layer, enabling real-time telemetry display.
 *
 * @section design_philosophy Design Philosophy
 * - Platform independence through pure virtual interface
 * - Asynchronous frame reception via Qt signals
 * - Thread-safe operation for real-time performance
 * - Extensible to support multiple CAN backends (virtual, hardware, networked)
 *
 * @section implementation_guide Implementation Guide
 * To create a concrete CAN backend:
 * 1. Derive from CanBackend
 * 2. Implement initialize() for hardware/interface setup
 * 3. Implement sendFrame() for frame transmission
 * 4. Implement processIncomingFrames() for reception handling
 * 5. Emit frameReceived() signal when frames arrive
 * 6. Emit errorOccurred() signal on errors
 *
 * @section dependencies Dependencies
 * - Qt 6.x (Core)
 * - CanTypes.h
 *
 * @section compiler_requirements Compiler Requirements
 * - g++ 7.0+ (C++17)
 * - clang 5.0+
 *
 * @example
 * @code{.cpp}
 * class SocketCanBackend : public CanBackend {
 * public:
 *     bool initialize(const QString &interface) override {
 *         // Open SocketCAN interface
 *         return openSocket(interface);
 *     }
 *
 *     void sendFrame(const CanFrame &frame) override {
 *         // Transmit frame to hardware
 *         write(socket, &frame, sizeof(frame));
 *     }
 *
 * protected:
 *     void processIncomingFrames() override {
 *         CanFrame frame;
 *         if (read(socket, &frame, sizeof(frame)) > 0) {
 *             emit frameReceived(frame);
 *         }
 *     }
 * };
 * @endcode
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#pragma once

#include "CanTypes.h"
#include <QObject>
#include <memory>

/**
 * @class CanBackend
 * @brief Abstract base class for platform-specific CAN bus communication.
 *
 * @details
 * CanBackend defines the interface contract that all platform-specific CAN implementations
 * must follow. It provides a Qt-based abstraction over hardware CAN interfaces, allowing
 * the application to work with SocketCAN, proprietary drivers, or virtual CAN interfaces
 * through a unified API.
 *
 * The class is designed for asynchronous operation: frame reception triggers Qt signals
 * that can be connected to any part of the application, maintaining loose coupling between
 * hardware layer and application logic.
 *
 * @note This is an abstract class and cannot be instantiated directly.
 *       Use concrete implementations like SocketCanBackend or VirtualCanBackend.
 *
 * @see CanFrame
 * @see SignalBus
 */
class CanBackend : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief Constructs a CanBackend instance.
     *
     * @param parent Optional parent QObject for Qt ownership hierarchy.
     *               If provided, this object will be deleted when parent is deleted.
     *
     * @note The constructor does not initialize hardware.
     *       Call initialize() after construction to set up the CAN interface.
     */
    explicit CanBackend(QObject *parent = nullptr);

    /**
     * @brief Destroys the CanBackend and releases any held resources.
     *
     * @details
     * Derived classes should override to perform cleanup of hardware resources,
     * close sockets, release device handles, etc.
     */
    virtual ~CanBackend();

    /**
     * @brief Initializes the CAN bus interface.
     *
     * @param interface Platform-specific interface identifier.
     *                  Examples: "can0", "vcan0" for SocketCAN,
     *                            "COM3" for serial CAN adapters,
     *                            "192.168.1.100:2000" for network CAN.
     *
     * @return true if initialization succeeded and interface is ready for communication.
     * @return false if initialization failed (interface not found, permission denied, etc.).
     *
     * @note Call this method before attempting to send or receive frames.
     * @note Emits errorOccurred() signal if initialization fails.
     *
     * @see errorOccurred()
     */
    virtual bool initialize(const QString &interface) = 0;

    /**
     * @brief Transmits a CAN frame to the bus.
     *
     * @param frame The CAN frame to transmit. Must have valid id, dlc, and data fields.
     *
     * @pre The interface must be initialized successfully via initialize().
     * @pre frame.dlc must be in range [0, 8].
     * @pre frame.id must be valid for the CAN protocol (11-bit or 29-bit identifier).
     *
     * @note This method may block briefly during transmission.
     * @note If transmission fails, implementations should emit errorOccurred() signal.
     *
     * @warning Calling this before successful initialize() results in undefined behavior.
     *
     * @see CanFrame
     * @see initialize()
     */
    virtual void sendFrame(const CanFrame &frame) = 0;

signals:
    /**
     * @brief Signal emitted when a CAN frame is received from the bus.
     *
     * @param frame The received CAN frame with populated id, dlc, data, and timestamp.
     *
     * @note This signal is emitted from the reception thread/event loop.
     * @note Connect to this signal to process incoming telemetry data.
     *
     * @see CanFrame
     */
    void frameReceived(const CanFrame &frame);

    /**
     * @brief Signal emitted when an error occurs during CAN operations.
     *
     * @param error Human-readable error description suitable for logging or display.
     *
     * @details
     * Common error scenarios:
     * - Interface initialization failure
     * - Frame transmission failure
     * - Bus-off condition
     * - Hardware disconnection
     *
     * @note Applications should monitor this signal for diagnostic and recovery purposes.
     */
    void errorOccurred(const QString &error);

protected:
    /**
     * @brief Processes incoming CAN frames from the hardware interface.
     *
     * @details
     * Derived classes must implement this method to:
     * 1. Read frames from the hardware interface (socket, driver API, etc.)
     * 2. Populate CanFrame structure with received data
     * 3. Emit frameReceived() signal for each valid frame
     * 4. Handle reception errors appropriately
     *
     * This method is typically called from a background thread or event loop
     * to ensure non-blocking frame reception.
     *
     * @note Implementations must be thread-safe if called from worker threads.
     * @note Use Qt::QueuedConnection when emitting signals from worker threads.
     *
     * @see frameReceived()
     */
    virtual void processIncomingFrames() = 0;
};
