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
#include <QtMath>
#include "model/SignalBus.h"
#include "model/VehicleData.h"

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

    // Create SignalBus instance (legacy compatibility)
    SignalBus signalBus;

    // Create VehicleData instance (Bosch DDU pattern)
    VehicleData vehicleData;

    // Create QML engine
    QQmlApplicationEngine engine;

    // Register both data models with QML context
    engine.rootContext()->setContextProperty("signalBus", &signalBus);
    engine.rootContext()->setContextProperty("vehicleData", &vehicleData);

    // Register display properties with QML context
    engine.rootContext()->setContextProperty("windowWidth", windowWidth);
    engine.rootContext()->setContextProperty("windowHeight", windowHeight);
    engine.rootContext()->setContextProperty("fullscreenMode", fullscreenMode);
    engine.rootContext()->setContextProperty("detectedWidth", detectedWidth);
    engine.rootContext()->setContextProperty("detectedHeight", detectedHeight);

    // High-frequency telemetry timer (Bosch DDU pattern: 100 Hz)
    QTimer telemetryTimer;
    QObject::connect(&telemetryTimer, &QTimer::timeout, [&vehicleData, &signalBus]() {
        static double time = 0.0;
        static int cycleCount = 0;

        // Realistic motorsport telemetry simulation
        // RPM follows a racing acceleration pattern
        double baseRpm = 2000.0 + 5500.0 * qSin(time * 0.3);  // Smooth 2000-7500 RPM sweep
        double rpmNoise = (qrand() % 100 - 50) * 0.5;  // ±25 RPM sensor noise
        double rpm = qMax(0.0, baseRpm + rpmNoise);

        // Speed correlates with RPM (simulates 5th gear acceleration)
        double speed = rpm * 0.035;  // ~70-260 km/h range

        // Gear calculation (realistic shift points)
        int gear = 1;
        if (rpm > 6500) gear = 6;
        else if (rpm > 5500) gear = 5;
        else if (rpm > 4500) gear = 4;
        else if (rpm > 3500) gear = 3;
        else if (rpm > 2500) gear = 2;

        // Throttle position (smooth sine wave)
        double throttle = 50.0 + 50.0 * qSin(time * 0.5);  // 0-100%

        // Coolant temperature (realistic heat-up)
        double coolantTemp = 70.0 + (rpm / 250.0) + (cycleCount / 100.0);
        coolantTemp = qMin(120.0, coolantTemp);

        // Oil temperature (lags behind coolant)
        double oilTemp = 75.0 + (rpm / 300.0) + (cycleCount / 120.0);
        oilTemp = qMin(135.0, oilTemp);

        // Oil pressure (increases with RPM)
        double oilPressure = 2.5 + (rpm / 2000.0);

        // Fuel consumption (decreases over time)
        static double fuelPercent = 84.0;
        fuelPercent -= 0.001;  // Slow burn
        if (fuelPercent < 0.0) fuelPercent = 100.0;  // Reset for demo

        // Update VehicleData (Q_PROPERTY pattern - direct binding)
        vehicleData.setRpm(rpm);
        vehicleData.setSpeed(speed);
        vehicleData.setGear(gear);
        vehicleData.setThrottle(throttle);
        vehicleData.setCoolantTemp(coolantTemp);
        vehicleData.setOilTemp(oilTemp);
        vehicleData.setOilPressure(oilPressure);
        vehicleData.setFuelPercent(fuelPercent);

        // Also update SignalBus for legacy components
        signalBus.setValue("EngineRPM", static_cast<int>(rpm));
        signalBus.setValue("VehicleSpeed", speed);
        signalBus.setValue("CoolantTemp", coolantTemp);
        signalBus.setValue("Gear", gear);

        time += 0.01;  // 10ms increment
        cycleCount++;
    });
    telemetryTimer.start(10); // 100 Hz update (Bosch DDU standard)

    const QUrl url(u"qrc:/ReikonDash/qml/App.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
