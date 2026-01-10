/**
 * @file    Logger.h
 * @brief   Centralized logging service for diagnostics and debugging.
 * @defgroup services_layer Services Layer
 * @{
 *
 * @details
 * Logger implements a singleton pattern to provide application-wide logging capabilities
 * with multiple severity levels (Debug, Info, Warning, Error). Logs are output to the
 * console and can be extended to support file logging, remote logging, or custom handlers.
 * Essential for debugging CAN communication issues, performance analysis, and field diagnostics
 * in motorsport environments.
 *
 * @section design_philosophy Design Philosophy
 * - Thread-safe singleton for global access
 * - Severity-based filtering for production vs. debug builds
 * - Qt integration for seamless message handling
 * - Extensible output backend (console, file, network)
 * - Minimal runtime overhead in release builds
 * - Timestamp-tagged messages for correlation
 *
 * @section usage_example Usage Example
 * @code{.cpp}
 * #include "Logger.h"
 *
 * // Using convenience methods
 * Logger::instance().info("Application started");
 * Logger::instance().debug("CAN interface initialized on vcan0");
 * Logger::instance().warning("Frame rate dropped below 30 FPS");
 * Logger::instance().error("Failed to open CAN socket");
 *
 * // Using generic log method with level
 * Logger::instance().log(Logger::Level::Info, "Engine RPM: 6500");
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

#include <QString>
#include <QObject>

/**
 * @class Logger
 * @brief Singleton logging service with severity levels.
 *
 * @details
 * Logger provides a centralized, thread-safe logging mechanism for the entire application.
 * All log messages are timestamped and tagged with severity levels, making it easy to
 * filter and analyze logs during development and in production.
 *
 * The singleton pattern ensures only one Logger instance exists, accessible globally via
 * Logger::instance(). This design prevents multiple log outputs and ensures consistent
 * log formatting throughout the application.
 *
 * @note This class cannot be copied or assigned (deleted copy/assignment operators).
 * @note All methods are thread-safe.
 *
 * @see Level
 */
class Logger : public QObject
{
    Q_OBJECT

public:
    /**
     * @enum Level
     * @brief Log message severity levels.
     *
     * @details
     * Defines the importance/severity of log messages. Can be used to filter
     * logs at runtime or during analysis.
     */
    enum class Level {
        Debug,   ///< Detailed diagnostic information for developers
        Info,    ///< General informational messages
        Warning, ///< Warning messages for potentially problematic situations
        Error    ///< Error messages for failures and critical issues
    };

    /**
     * @brief Returns the singleton Logger instance.
     *
     * @return Reference to the global Logger instance.
     *
     * @note First call creates the instance; subsequent calls return the same instance.
     * @note Thread-safe initialization (C++11 magic statics).
     */
    static Logger& instance();

    /**
     * @brief Logs a message with specified severity level.
     *
     * @param level The severity level of the message.
     * @param message The log message content.
     *
     * @details
     * Formats the message with timestamp and level prefix, then outputs to
     * the configured logging backend (console by default).
     *
     * Format: [YYYY-MM-DD HH:MM:SS.zzz] [LEVEL] message
     *
     * @note Thread-safe.
     */
    void log(Level level, const QString &message);

    /**
     * @brief Logs a debug-level message.
     *
     * @param message The debug message content.
     *
     * @details
     * Convenience method equivalent to log(Level::Debug, message).
     * Debug messages are typically suppressed in release builds.
     */
    void debug(const QString &message);

    /**
     * @brief Logs an info-level message.
     *
     * @param message The informational message content.
     *
     * @details
     * Convenience method equivalent to log(Level::Info, message).
     * Info messages represent normal operational events.
     */
    void info(const QString &message);

    /**
     * @brief Logs a warning-level message.
     *
     * @param message The warning message content.
     *
     * @details
     * Convenience method equivalent to log(Level::Warning, message).
     * Warnings indicate potentially problematic situations that don't prevent operation.
     */
    void warning(const QString &message);

    /**
     * @brief Logs an error-level message.
     *
     * @param message The error message content.
     *
     * @details
     * Convenience method equivalent to log(Level::Error, message).
     * Errors indicate failures or critical issues requiring attention.
     */
    void error(const QString &message);

private:
    /**
     * @brief Private constructor (singleton pattern).
     *
     * @details
     * Use instance() to access the Logger instead of constructing directly.
     */
    Logger();

    /**
     * @brief Private destructor (singleton pattern).
     */
    ~Logger();

    /**
     * @brief Deleted copy constructor (singleton pattern).
     */
    Logger(const Logger&) = delete;

    /**
     * @brief Deleted assignment operator (singleton pattern).
     */
    Logger& operator=(const Logger&) = delete;
};

/** @} */ // end of services_layer group
