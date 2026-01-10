/**
 * @file    CanBackend.h
 * @brief   Abstract interface for CAN bus communication backend.
 *
 * CanBackend provides a platform-abstraction layer for CAN bus operations, allowing
 * the Reikon Dash application to communicate with vehicle CAN networks through various
 * hardware interfaces (SocketCAN on Linux, hardware-specific drivers, etc.). The class
 * uses Qt's signal/slot mechanism to deliver received CAN frames asynchronously to the
 * application layer, enabling real-time telemetry display.
 *
 * Design Philosophy:
 * - Platform independence through pure virtual interface
 * - Asynchronous frame reception via Qt signals
 * - Thread-safe operation for real-time performance
 * - Extensible to support multiple CAN backends (virtual, hardware, networked)
 *
 * Dependencies: Qt 6.x (Core), CanTypes.h
 * Compiler: g++ 7.0+ (C++17), clang 5.0+
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

class CanBackend : public QObject
{
    Q_OBJECT

public:
    explicit CanBackend(QObject *parent = nullptr);
    virtual ~CanBackend();

    virtual bool initialize(const QString &interface) = 0;
    virtual void sendFrame(const CanFrame &frame) = 0;

signals:
    void frameReceived(const CanFrame &frame);
    void errorOccurred(const QString &error);

protected:
    virtual void processIncomingFrames() = 0;
};
