/**
 * @file    SignalBus.cpp
 * @brief   Implementation of the SignalBus telemetry distribution system.
 *
 * Implements a lightweight publish-subscribe system for distributing vehicle telemetry
 * signals from CAN bus decoders to QML UI components. Signals are stored as named
 * QVariant values and changes trigger Qt signals for automatic UI binding updates.
 * Change detection prevents unnecessary signal emissions for improved performance.
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#include "SignalBus.h"

SignalBus::SignalBus(QObject *parent)
    : QObject(parent)
{
}

SignalBus::~SignalBus()
{
}

QVariant SignalBus::getValue(const QString &signalName) const
{
    return m_signals.value(signalName);
}

void SignalBus::setValue(const QString &signalName, const QVariant &value)
{
    if (m_signals.value(signalName) != value) {
        m_signals[signalName] = value;
        emit signalChanged(signalName, value);
    }
}
