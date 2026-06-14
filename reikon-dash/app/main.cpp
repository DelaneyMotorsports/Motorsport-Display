/**
 * @file    main.cpp
 * @brief   Application entry point for Reikon Dash.
 *
 * Initializes the Qt application framework and QML engine, loading the main App.qml
 * interface. This file bootstraps the entire Reikon Dash system, including CAN backend
 * initialization, signal bus setup, and QML context registration. Implements proper
 * error handling to exit gracefully if QML fails to load.
 *
 * Design Philosophy:
 * - Clean separation of C++ backend and QML frontend
 * - Fail-fast on initialization errors
 * - Qt 6 modern practices (QUrl literals, QQmlApplicationEngine)
 *
 * Dependencies: Qt 6.x (Gui, Qml, Quick)
 * Compiler: g++ 7.0+ (C++17), clang 5.0+
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include <QSurfaceFormat>
#include "model/SignalBus.h"

int main(int argc, char *argv[])
{
    // OpenGL ES 2.0 configuration for Raspberry Pi 5
    QSurfaceFormat format;
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    format.setVersion(2, 0);
    format.setSwapBehavior(QSurfaceFormat::DoubleBuffer);
    format.setSwapInterval(1);  // V-sync for 60 FPS cap
    QSurfaceFormat::setDefaultFormat(format);

    // Performance hints for embedded systems
    qputenv("QSG_RENDER_LOOP", "basic");
    qputenv("QT_QPA_EGLFS_PHYSICAL_WIDTH", "1920");
    qputenv("QT_QPA_EGLFS_PHYSICAL_HEIGHT", "720");

    QGuiApplication app(argc, argv);

    // Create SignalBus instance
    SignalBus signalBus;

    // Create QML engine
    QQmlApplicationEngine engine;

    // Register SignalBus with QML context
    engine.rootContext()->setContextProperty("signalBus", &signalBus);

    // Test timer for UI development (simulates CAN data)
    QTimer testTimer;
    QObject::connect(&testTimer, &QTimer::timeout, [&signalBus]() {
        static int rpm = 2000;
        static bool ascending = true;

        // Simulate RPM ramping up and down
        if (ascending) {
            rpm += 150;
            if (rpm >= 7500) ascending = false;
        } else {
            rpm -= 150;
            if (rpm <= 2000) ascending = true;
        }

        signalBus.setValue("EngineRPM", rpm);
        signalBus.setValue("VehicleSpeed", rpm / 30.0);  // ~0-250 km/h
        signalBus.setValue("CoolantTemp", 70 + (rpm / 150.0));  // 70-120°C
        signalBus.setValue("Gear", qMin(6, qMax(1, rpm / 1200)));  // 1-6
    });
    testTimer.start(50); // 20 Hz update

    const QUrl url(u"qrc:/ReikonDash/qml/App.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
