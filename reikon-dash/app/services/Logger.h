/**
 * @file    Logger.h
 * @brief   Centralized logging service for diagnostics and debugging.
 *
 * Logger implements a singleton pattern to provide application-wide logging capabilities
 * with multiple severity levels (Debug, Info, Warning, Error). Logs are output to the
 * console and can be extended to support file logging, remote logging, or custom handlers.
 * Essential for debugging CAN communication issues, performance analysis, and field diagnostics
 * in motorsport environments.
 *
 * Design Philosophy:
 * - Thread-safe singleton for global access
 * - Severity-based filtering for production vs. debug builds
 * - Qt integration for seamless message handling
 * - Extensible output backend (console, file, network)
 * - Minimal runtime overhead in release builds
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

#include <QString>
#include <QObject>

class Logger : public QObject
{
    Q_OBJECT

public:
    enum class Level {
        Debug,
        Info,
        Warning,
        Error
    };

    static Logger& instance();

    void log(Level level, const QString &message);
    void debug(const QString &message);
    void info(const QString &message);
    void warning(const QString &message);
    void error(const QString &message);

private:
    Logger();
    ~Logger();
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;
};
