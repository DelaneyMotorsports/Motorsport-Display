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
