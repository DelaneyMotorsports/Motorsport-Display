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
#include <QCommandLineParser>
#include <QScreen>
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

    QGuiApplication app(argc, argv);
    app.setApplicationName("Reikon Dash");
    app.setApplicationVersion("1.0.0");

    // Command-line argument parsing
    QCommandLineParser parser;
    parser.setApplicationDescription("Reikon Dash - Motorsport Telemetry Display");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption widthOption(QStringList() << "w" << "width",
                                   "Display width in pixels (default: auto-detect)", "width");
    QCommandLineOption heightOption(QStringList() << "h" << "height",
                                    "Display height in pixels (default: auto-detect)", "height");
    QCommandLineOption fullscreenOption(QStringList() << "f" << "fullscreen",
                                        "Run in fullscreen mode (default: true for kiosk)");
    QCommandLineOption windowedOption(QStringList() << "windowed",
                                      "Run in windowed mode instead of fullscreen");

    parser.addOption(widthOption);
    parser.addOption(heightOption);
    parser.addOption(fullscreenOption);
    parser.addOption(windowedOption);
    parser.process(app);

    // Detect screen resolution
    QScreen *screen = QGuiApplication::primaryScreen();
    QRect screenGeometry = screen->geometry();
    int detectedWidth = screenGeometry.width();
    int detectedHeight = screenGeometry.height();

    // Use command-line override or detected resolution
    int windowWidth = parser.value(widthOption).toInt();
    int windowHeight = parser.value(heightOption).toInt();

    // Default to detected resolution if not specified
    if (windowWidth == 0) windowWidth = detectedWidth;
    if (windowHeight == 0) windowHeight = detectedHeight;

    // Determine fullscreen mode (default true unless --windowed specified)
    bool fullscreenMode = !parser.isSet(windowedOption);

    // Update performance hints with actual resolution
    qputenv("QSG_RENDER_LOOP", "basic");
    qputenv("QT_QPA_EGLFS_PHYSICAL_WIDTH", QString::number(windowWidth).toLatin1());
    qputenv("QT_QPA_EGLFS_PHYSICAL_HEIGHT", QString::number(windowHeight).toLatin1());

    // Create SignalBus instance
    SignalBus signalBus;

    // Create QML engine
    QQmlApplicationEngine engine;

    // Register SignalBus with QML context
    engine.rootContext()->setContextProperty("signalBus", &signalBus);

    // Register display properties with QML context
    engine.rootContext()->setContextProperty("windowWidth", windowWidth);
    engine.rootContext()->setContextProperty("windowHeight", windowHeight);
    engine.rootContext()->setContextProperty("fullscreenMode", fullscreenMode);
    engine.rootContext()->setContextProperty("detectedWidth", detectedWidth);
    engine.rootContext()->setContextProperty("detectedHeight", detectedHeight);

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
