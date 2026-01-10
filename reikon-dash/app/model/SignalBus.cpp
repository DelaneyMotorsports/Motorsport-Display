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
