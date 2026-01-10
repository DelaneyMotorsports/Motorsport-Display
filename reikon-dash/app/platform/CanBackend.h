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
