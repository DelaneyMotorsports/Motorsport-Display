/**
 * @file    SignalBus.h
 * @brief   Central signal distribution hub for real-time telemetry data.
 *
 * SignalBus provides a publish-subscribe mechanism for distributing decoded vehicle
 * telemetry signals throughout the Reikon Dash application. CAN frames are decoded
 * into named signals (e.g., "EngineRPM", "ThrottlePosition") and published through
 * this bus, allowing QML UI components to subscribe and react to data changes in
 * real-time without tight coupling to the CAN layer.
 *
 * Design Philosophy:
 * - Decoupled communication between data sources and UI consumers
 * - Type-safe signal storage using QVariant for flexibility
 * - Qt property bindings for automatic UI updates
 * - Thread-safe operation via Qt's event system
 * - Scalable to hundreds of simultaneous signals
 *
 * Dependencies: Qt 6.x (Core)
 * Compiler: g++ 7.0+ (C++17), clang 5.0+
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#pragma once

#include <QObject>
#include <QVariantMap>

class SignalBus : public QObject
{
    Q_OBJECT

public:
    explicit SignalBus(QObject *parent = nullptr);
    ~SignalBus();

    Q_INVOKABLE QVariant getValue(const QString &signalName) const;
    void setValue(const QString &signalName, const QVariant &value);

signals:
    void signalChanged(const QString &signalName, const QVariant &value);

private:
    QVariantMap m_signals;
};
