/**
 * @file    CanBackend.cpp
 * @brief   Implementation of CAN backend base class.
 *
 * Provides the base implementation for the CanBackend abstract interface.
 * Concrete implementations (e.g., SocketCanBackend, VirtualCanBackend) derive
 * from this class and implement platform-specific CAN communication logic.
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#include "CanBackend.h"

CanBackend::CanBackend(QObject *parent)
    : QObject(parent)
{
}

CanBackend::~CanBackend()
{
}
