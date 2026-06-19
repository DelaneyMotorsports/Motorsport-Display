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
#include <QRandomGenerator>
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
    // Realistic racing lap simulation with gear changes
    QTimer telemetryTimer;
    QObject::connect(&telemetryTimer, &QTimer::timeout, [&vehicleData, &signalBus]() {
        static double lapTime = 0.0;  // Seconds into lap
        static int cycleCount = 0;
        static double batteryPercent = 84.0;  // Battery/energy state of charge
        static double prevSpeed = 0.0;  // For brake detection

        // Lap phases (seconds): Accel → Straight → Brake → Corner → Repeat
        const double LAP_DURATION = 35.0;  // Faster 35 second lap
        double lapPhase = fmod(lapTime, LAP_DURATION);

        int gear = 1;
        double rpm = 2000.0;
        double throttle = 0.0;
        double speed = 0.0;

        // Realistic racing lap simulation - AGGRESSIVE
        if (lapPhase < 5.0) {
            // Phase 1: FAST acceleration through gears (0-5s)
            double accelProgress = lapPhase / 5.0;

            if (accelProgress < 0.12) {
                // 1st gear: 2000-7200 RPM FAST
                gear = 1;
                rpm = 2000.0 + (accelProgress / 0.12) * 5200.0;
                throttle = 100.0;
                speed = rpm * 0.015;
            } else if (accelProgress < 0.24) {
                // Shift 1→2: brief throttle lift
                double shiftProg = (accelProgress - 0.12) / 0.12;
                gear = shiftProg < 0.3 ? 1 : 2;
                rpm = shiftProg < 0.3 ? 7200.0 - (shiftProg / 0.3) * 3000.0 : 4200.0 + (shiftProg - 0.3) / 0.7 * 3300.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
                speed = 50.0 + shiftProg * 30.0;
            } else if (accelProgress < 0.36) {
                // 2nd gear: 4200-7500 RPM FAST
                gear = 2;
                rpm = 4200.0 + ((accelProgress - 0.24) / 0.12) * 3300.0;
                throttle = 100.0;
                speed = 80.0 + ((accelProgress - 0.24) / 0.12) * 40.0;
            } else if (accelProgress < 0.48) {
                // Shift 2→3
                double shiftProg = (accelProgress - 0.36) / 0.12;
                gear = shiftProg < 0.3 ? 2 : 3;
                rpm = shiftProg < 0.3 ? 7500.0 - (shiftProg / 0.3) * 2500.0 : 5000.0 + (shiftProg - 0.3) / 0.7 * 2700.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
                speed = 120.0 + shiftProg * 20.0;
            } else if (accelProgress < 0.63) {
                // 3rd gear: 5000-7700 RPM FAST
                gear = 3;
                rpm = 5000.0 + ((accelProgress - 0.48) / 0.15) * 2700.0;
                throttle = 100.0;
                speed = 140.0 + ((accelProgress - 0.48) / 0.15) * 30.0;
            } else if (accelProgress < 0.78) {
                // Shift 3→4
                double shiftProg = (accelProgress - 0.63) / 0.15;
                gear = shiftProg < 0.3 ? 3 : 4;
                rpm = shiftProg < 0.3 ? 7700.0 - (shiftProg / 0.3) * 2200.0 : 5500.0 + (shiftProg - 0.3) / 0.7 * 2500.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
                speed = 170.0 + shiftProg * 20.0;
            } else {
                // 4th gear: 5500-8000 RPM FAST
                gear = 4;
                rpm = 5500.0 + ((accelProgress - 0.78) / 0.22) * 2500.0;
                throttle = 100.0;
                speed = 190.0 + ((accelProgress - 0.78) / 0.22) * 30.0;
            }

        } else if (lapPhase < 12.0) {
            // Phase 2: High-speed straight, hit rev limiter in 5th (5-12s)
            double straightProg = (lapPhase - 5.0) / 7.0;

            if (straightProg < 0.15) {
                // Shift 4→5
                double shiftProg = straightProg / 0.15;
                gear = shiftProg < 0.3 ? 4 : 5;
                rpm = shiftProg < 0.3 ? 8000.0 - (shiftProg / 0.3) * 2000.0 : 6000.0 + (shiftProg - 0.3) / 0.7 * 2200.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
                speed = 220.0 + shiftProg * 10.0;
            } else {
                // 5th gear: bounce off rev limiter at 8200 RPM
                gear = 5;
                double rpmTarget = 6000.0 + (straightProg - 0.15) / 0.85 * 2200.0;
                // Rev limiter: cut ignition above 8200, bounces between 8150-8200
                if (rpmTarget > 8200.0) {
                    double bounce = QRandomGenerator::global()->bounded(50);
                    rpm = 8150.0 + bounce;
                    throttle = rpmTarget > 8200 ? 50.0 : 100.0;  // Fluttering throttle at limiter
                } else {
                    rpm = rpmTarget;
                    throttle = 100.0;
                }
                speed = 230.0 + (straightProg - 0.15) * 30.0;
            }

        } else if (lapPhase < 20.0) {
            // Phase 3: HARD braking and downshifts (12-20s)
            double brakeProg = (lapPhase - 12.0) / 8.0;
            throttle = qMax(0.0, 100.0 - brakeProg * 150.0);  // Braking

            if (brakeProg < 0.20) {
                // 5th gear coasting
                gear = 5;
                rpm = 8000.0 - brakeProg / 0.20 * 2500.0;
                speed = 250.0 - brakeProg / 0.20 * 70.0;
            } else if (brakeProg < 0.35) {
                // Downshift 5→4
                gear = 4;
                rpm = 5500.0 + (brakeProg - 0.20) / 0.15 * 1000.0;  // Rev match
                speed = 180.0 - (brakeProg - 0.20) / 0.15 * 30.0;
            } else if (brakeProg < 0.50) {
                // Downshift 4→3
                gear = 3;
                rpm = 5000.0 + (brakeProg - 0.35) / 0.15 * 1200.0;
                speed = 150.0 - (brakeProg - 0.35) / 0.15 * 30.0;
            } else if (brakeProg < 0.65) {
                // Downshift 3→2
                gear = 2;
                rpm = 4500.0 + (brakeProg - 0.50) / 0.15 * 1500.0;
                speed = 120.0 - (brakeProg - 0.50) / 0.15 * 40.0;
            } else {
                // Final braking in 2nd
                gear = 2;
                rpm = qMax(3000.0, 6000.0 - (brakeProg - 0.65) / 0.35 * 3000.0);
                speed = qMax(60.0, 80.0 - (brakeProg - 0.65) / 0.35 * 20.0);
            }

        } else {
            // Phase 4: AGGRESSIVE cornering and back straight (20-35s)
            double cornerProg = (lapPhase - 20.0) / 15.0;

            if (cornerProg < 0.4) {
                // Exit corner in 2nd, rev hard
                gear = 2;
                rpm = 3500.0 + (cornerProg / 0.4) * 3700.0;  // 3500→7200 fast
                throttle = 80.0 + (cornerProg / 0.4) * 20.0;
                speed = 70.0 + (cornerProg / 0.4) * 60.0;
            } else {
                // Quick 2nd→3rd for back straight
                double prog = (cornerProg - 0.4) / 0.6;
                if (prog < 0.2) {
                    gear = prog < 0.1 ? 2 : 3;
                    rpm = prog < 0.1 ? 7200.0 - (prog / 0.1) * 2200.0 : 5000.0 + (prog - 0.1) / 0.1 * 2500.0;
                    throttle = prog < 0.1 ? 0.0 : 100.0;
                    speed = 130.0 + prog * 30.0;
                } else {
                    // 3rd gear hard acceleration
                    gear = 3;
                    rpm = 5000.0 + ((prog - 0.2) / 0.8) * 2500.0;
                    throttle = 100.0;
                    speed = 140.0 + ((prog - 0.2) / 0.8) * 50.0;
                }
            }
        }

        // Add sensor noise
        double rpmNoise = (QRandomGenerator::global()->bounded(100) - 50) * 0.3;
        rpm = qMax(1000.0, qMin(10000.0, rpm + rpmNoise));

        // Temperature simulation
        double coolantTemp = 75.0 + (rpm / 300.0) + (throttle / 10.0);
        coolantTemp = qMin(115.0, coolantTemp);
        double oilTemp = 80.0 + (rpm / 350.0) + (throttle / 12.0);
        oilTemp = qMin(130.0, oilTemp);
        double oilPressure = 2.0 + (rpm / 1800.0);

        // Battery/Energy management (hybrid/electric simulation)
        // Detect braking (speed decreasing)
        bool isBraking = (speed < prevSpeed - 5.0);  // Speed dropped >5 kph

        if (throttle > 80.0) {
            // Hard acceleration: DRAIN battery fast
            batteryPercent -= 0.015;  // High discharge rate
        } else if (throttle > 50.0) {
            // Moderate throttle: slower drain
            batteryPercent -= 0.005;
        } else if (isBraking && speed > 30.0) {
            // Regenerative braking: CHARGE battery (but less than drain)
            batteryPercent += 0.008;  // Moderate regen
        } else if (throttle < 20.0 && speed > 50.0) {
            // Coasting: light regen
            batteryPercent += 0.002;
        }

        // Clamp battery percentage
        batteryPercent = qMax(5.0, qMin(100.0, batteryPercent));

        // Reset when very low (for demo continuity)
        if (batteryPercent < 10.0 && lapPhase < 1.0) {
            batteryPercent = 90.0;  // Pit stop recharge
        }

        prevSpeed = speed;

        // Update telemetry
        vehicleData.setRpm(rpm);
        vehicleData.setSpeed(speed);
        vehicleData.setGear(gear);
        vehicleData.setThrottle(throttle);
        vehicleData.setCoolantTemp(coolantTemp);
        vehicleData.setOilTemp(oilTemp);
        vehicleData.setOilPressure(oilPressure);
        vehicleData.setFuelPercent(batteryPercent);

        signalBus.setValue("EngineRPM", static_cast<int>(rpm));
        signalBus.setValue("VehicleSpeed", speed);
        signalBus.setValue("CoolantTemp", coolantTemp);
        signalBus.setValue("Gear", gear);

        lapTime += 0.01;
        cycleCount++;
    });
    telemetryTimer.start(10); // 100 Hz update (Bosch DDU standard)

    const QUrl url(QStringLiteral("qrc:/ReikonDash/qml/App.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
