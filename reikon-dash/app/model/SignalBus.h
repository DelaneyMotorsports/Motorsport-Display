/**
 * @file    SignalBus.h
 * @brief   Central signal distribution hub for real-time telemetry data.
 * @defgroup model_layer Model Layer
 * @{
 *
 * @details
 * SignalBus provides a publish-subscribe mechanism for distributing decoded vehicle
 * telemetry signals throughout the Reikon Dash application. CAN frames are decoded
 * into named signals (e.g., "EngineRPM", "ThrottlePosition") and published through
 * this bus, allowing QML UI components to subscribe and react to data changes in
 * real-time without tight coupling to the CAN layer.
 *
 * @section design_philosophy Design Philosophy
 * - Decoupled communication between data sources and UI consumers
 * - Type-safe signal storage using QVariant for flexibility
 * - Qt property bindings for automatic UI updates
 * - Thread-safe operation via Qt's event system
 * - Scalable to hundreds of simultaneous signals
 * - Change detection to prevent redundant signal emissions
 *
 * @section usage_example Usage Example
 * @code{.cpp}
 * // C++ side - Publishing signals
 * SignalBus *bus = new SignalBus(this);
 * bus->setValue("EngineRPM", 6500);
 * bus->setValue("ThrottlePosition", 85.5);
 * bus->setValue("GearPosition", 3);
 *
 * // QML side - Consuming signals
 * Connections {
 *     target: signalBus
 *     function onSignalChanged(signalName, value) {
 *         if (signalName === "EngineRPM") {
 *             rpmGauge.value = value;
 *         }
 *     }
 * }
 *
 * // Or direct property binding in QML
 * property real rpm: signalBus.getValue("EngineRPM")
 * @endcode
 *
 * @section dependencies Dependencies
 * - Qt 6.x (Core)
 *
 * @section compiler_requirements Compiler Requirements
 * - g++ 7.0+ (C++17)
 * - clang 5.0+
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#pragma once

#include <QObject>
#include <QVariantMap>

/**
 * @class SignalBus
 * @brief Publish-subscribe hub for distributing telemetry signals.
 *
 * @details
 * SignalBus acts as a central message broker between data producers (CAN decoders,
 * sensor processors) and data consumers (QML UI components, data loggers). It uses
 * Qt's signal/slot mechanism to notify subscribers of value changes, enabling reactive
 * UI updates without polling.
 *
 * Signals are identified by string names (e.g., "EngineRPM") and stored as QVariant
 * values, allowing type flexibility while maintaining Qt's type safety through the
 * meta-object system.
 *
 * The class is designed to be exposed to QML via QQmlContext::setContextProperty(),
 * making all signals accessible from the UI layer.
 *
 * @note Only emits signalChanged() when the value actually changes (equality check).
 * @note All public methods are thread-safe when called from Qt event threads.
 *
 * @see CanBackend
 */
class SignalBus : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief Constructs a SignalBus instance.
     *
     * @param parent Optional parent QObject for Qt ownership hierarchy.
     */
    explicit SignalBus(QObject *parent = nullptr);

    /**
     * @brief Destroys the SignalBus and clears all stored signals.
     */
    ~SignalBus();

    /**
     * @brief Retrieves the current value of a signal.
     *
     * @param signalName The name of the signal to retrieve (e.g., "EngineRPM").
     *
     * @return The current value of the signal as a QVariant.
     * @return Invalid QVariant if the signal does not exist.
     *
     * @note This method is marked Q_INVOKABLE for QML accessibility.
     * @note If the signal has never been set, returns an invalid QVariant.
     *
     * @see setValue()
     */
    Q_INVOKABLE QVariant getValue(const QString &signalName) const;

    /**
     * @brief Updates or creates a signal with a new value.
     *
     * @param signalName The name of the signal to update/create (e.g., "ThrottlePosition").
     * @param value The new value for the signal. Can be any type supported by QVariant
     *              (int, double, QString, bool, etc.).
     *
     * @details
     * If the signal already exists and the new value differs from the current value,
     * the signalChanged() signal is emitted. If the values are equal (per QVariant::operator==),
     * no signal is emitted to avoid unnecessary UI updates.
     *
     * If the signal does not exist, it is created and signalChanged() is emitted.
     *
     * @note Typical usage: call this from CAN frame decoder after extracting signal value.
     * @note Signal names should follow consistent naming conventions (e.g., PascalCase).
     *
     * @see signalChanged()
     * @see getValue()
     */
    void setValue(const QString &signalName, const QVariant &value);

signals:
    /**
     * @brief Signal emitted when a signal value changes.
     *
     * @param signalName The name of the signal that changed.
     * @param value The new value of the signal.
     *
     * @details
     * Connect to this signal to receive notifications about all signal changes.
     * Subscribers can filter by signalName to react only to specific signals.
     *
     * In QML, use Connections or JavaScript functions to handle this signal:
     * @code{.qml}
     * Connections {
     *     target: signalBus
     *     function onSignalChanged(signalName, value) {
     *         console.log(signalName + " changed to " + value);
     *     }
     * }
     * @endcode
     *
     * @note Only emitted when the value actually changes (not on redundant setValue() calls).
     * @note Signal emission is thread-safe via Qt::QueuedConnection from non-GUI threads.
     */
    void signalChanged(const QString &signalName, const QVariant &value);

private:
    /**
     * @brief Internal storage for all signals.
     *
     * @details
     * Maps signal names (QString) to their current values (QVariant).
     * Provides O(1) average-case lookup and insertion performance.
     */
    QVariantMap m_signals;
};

/** @} */ // end of model_layer group
