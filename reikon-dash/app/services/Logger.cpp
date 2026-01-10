#include "Logger.h"
#include <QDebug>
#include <QDateTime>

Logger::Logger()
{
}

Logger::~Logger()
{
}

Logger& Logger::instance()
{
    static Logger instance;
    return instance;
}

void Logger::log(Level level, const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
    QString levelStr;

    switch (level) {
        case Level::Debug:   levelStr = "DEBUG"; break;
        case Level::Info:    levelStr = "INFO"; break;
        case Level::Warning: levelStr = "WARN"; break;
        case Level::Error:   levelStr = "ERROR"; break;
    }

    qDebug() << QString("[%1] [%2] %3").arg(timestamp, levelStr, message);
}

void Logger::debug(const QString &message)   { log(Level::Debug, message); }
void Logger::info(const QString &message)    { log(Level::Info, message); }
void Logger::warning(const QString &message) { log(Level::Warning, message); }
void Logger::error(const QString &message)   { log(Level::Error, message); }
