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

        // Tremec TR-6060 6-speed gear ratios with 3.69:1 final drive
        const double TIRE_DIAMETER = 28.0;  // inches (275/35R20)
        const double FINAL_DRIVE = 3.69;
        const double GEAR_RATIOS[] = {0.0, 2.97, 2.07, 1.43, 1.00, 0.84, 0.56};  // Index 0 unused, 1-6 for gears

        // Calculate speed from RPM and gear (mph)
        auto calculateSpeed = [&](double rpm, int gear) -> double {
            if (gear < 1 || gear > 6) return 0.0;
            return (rpm * TIRE_DIAMETER) / (GEAR_RATIOS[gear] * FINAL_DRIVE * 336.0);
        };

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
            } else if (accelProgress < 0.24) {
                // Shift 1→2: brief throttle lift
                double shiftProg = (accelProgress - 0.12) / 0.12;
                gear = shiftProg < 0.3 ? 1 : 2;
                rpm = shiftProg < 0.3 ? 7200.0 - (shiftProg / 0.3) * 3000.0 : 4200.0 + (shiftProg - 0.3) / 0.7 * 3300.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
            } else if (accelProgress < 0.36) {
                // 2nd gear: 4200-7500 RPM FAST
                gear = 2;
                rpm = 4200.0 + ((accelProgress - 0.24) / 0.12) * 3300.0;
                throttle = 100.0;
            } else if (accelProgress < 0.48) {
                // Shift 2→3
                double shiftProg = (accelProgress - 0.36) / 0.12;
                gear = shiftProg < 0.3 ? 2 : 3;
                rpm = shiftProg < 0.3 ? 7500.0 - (shiftProg / 0.3) * 2500.0 : 5000.0 + (shiftProg - 0.3) / 0.7 * 2700.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
            } else if (accelProgress < 0.63) {
                // 3rd gear: 5000-7700 RPM FAST
                gear = 3;
                rpm = 5000.0 + ((accelProgress - 0.48) / 0.15) * 2700.0;
                throttle = 100.0;
            } else if (accelProgress < 0.78) {
                // Shift 3→4
                double shiftProg = (accelProgress - 0.63) / 0.15;
                gear = shiftProg < 0.3 ? 3 : 4;
                rpm = shiftProg < 0.3 ? 7700.0 - (shiftProg / 0.3) * 2200.0 : 5500.0 + (shiftProg - 0.3) / 0.7 * 2500.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
            } else {
                // 4th gear: 5500-8000 RPM FAST
                gear = 4;
                rpm = 5500.0 + ((accelProgress - 0.78) / 0.22) * 2500.0;
                throttle = 100.0;
            }
            speed = calculateSpeed(rpm, gear);

        } else if (lapPhase < 12.0) {
            // Phase 2: High-speed straight, hit rev limiter in 5th (5-12s)
            double straightProg = (lapPhase - 5.0) / 7.0;

            if (straightProg < 0.15) {
                // Shift 4→5
                double shiftProg = straightProg / 0.15;
                gear = shiftProg < 0.3 ? 4 : 5;
                rpm = shiftProg < 0.3 ? 8000.0 - (shiftProg / 0.3) * 2000.0 : 6000.0 + (shiftProg - 0.3) / 0.7 * 2200.0;
                throttle = shiftProg < 0.3 ? 0.0 : 100.0;
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
            }
            speed = calculateSpeed(rpm, gear);

        } else if (lapPhase < 20.0) {
            // Phase 3: HARD braking and downshifts (12-20s)
            double brakeProg = (lapPhase - 12.0) / 8.0;
            throttle = qMax(0.0, 100.0 - brakeProg * 150.0);  // Braking

            if (brakeProg < 0.20) {
                // 5th gear coasting
                gear = 5;
                rpm = 8000.0 - brakeProg / 0.20 * 2500.0;
            } else if (brakeProg < 0.35) {
                // Downshift 5→4
                gear = 4;
                rpm = 5500.0 + (brakeProg - 0.20) / 0.15 * 1000.0;  // Rev match
            } else if (brakeProg < 0.50) {
                // Downshift 4→3
                gear = 3;
                rpm = 5000.0 + (brakeProg - 0.35) / 0.15 * 1200.0;
            } else if (brakeProg < 0.65) {
                // Downshift 3→2
                gear = 2;
                rpm = 4500.0 + (brakeProg - 0.50) / 0.15 * 1500.0;
            } else {
                // Final braking in 2nd
                gear = 2;
                rpm = qMax(3000.0, 6000.0 - (brakeProg - 0.65) / 0.35 * 3000.0);
            }
            speed = calculateSpeed(rpm, gear);

        } else {
            // Phase 4: AGGRESSIVE cornering and back straight (20-35s)
            double cornerProg = (lapPhase - 20.0) / 15.0;

            if (cornerProg < 0.4) {
                // Exit corner in 2nd, rev hard
                gear = 2;
                rpm = 3500.0 + (cornerProg / 0.4) * 3700.0;  // 3500→7200 fast
                throttle = 80.0 + (cornerProg / 0.4) * 20.0;
            } else {
                // Quick 2nd→3rd for back straight
                double prog = (cornerProg - 0.4) / 0.6;
                if (prog < 0.2) {
                    gear = prog < 0.1 ? 2 : 3;
                    rpm = prog < 0.1 ? 7200.0 - (prog / 0.1) * 2200.0 : 5000.0 + (prog - 0.1) / 0.1 * 2500.0;
                    throttle = prog < 0.1 ? 0.0 : 100.0;
                } else {
                    // 3rd gear hard acceleration
                    gear = 3;
                    rpm = 5000.0 + ((prog - 0.2) / 0.8) * 2500.0;
                    throttle = 100.0;
                }
            }
            speed = calculateSpeed(rpm, gear);
        }

        // Add sensor noise
        double rpmNoise = (QRandomGenerator::global()->bounded(100) - 50) * 0.3;
        rpm = qMax(1000.0, qMin(10000.0, rpm + rpmNoise));

        // Temperature simulation
        double coolantTemp = 75.0 + (rpm / 300.0) + (throttle / 10.0);
        coolantTemp = qMin(115.0, coolantTemp);
        double oilTemp = 80.0 + (rpm / 350.0) + (throttle / 12.0);
        oilTemp = qMin(130.0, oilTemp);

        // Dry sump oil pressure (LT4/M178 style)
        // Higher pressures than wet sump: 40 PSI idle → 100 PSI at redline
        double oilPressure = 0.0;
        if (rpm < 1000.0) {
            oilPressure = 35.0 + (rpm / 1000.0) * 10.0;  // 35-45 PSI at idle
        } else if (rpm < 3000.0) {
            oilPressure = 45.0 + ((rpm - 1000.0) / 2000.0) * 15.0;  // 45-60 PSI
        } else if (rpm < 6000.0) {
            oilPressure = 60.0 + ((rpm - 3000.0) / 3000.0) * 20.0;  // 60-80 PSI
        } else {
            oilPressure = 80.0 + ((rpm - 6000.0) / 2000.0) * 20.0;  // 80-100 PSI
            oilPressure = qMin(105.0, oilPressure);  // Cap at 105 PSI
        }

        // Boost/Vacuum calculation (LT4 supercharged - Eaton TVS R2650)
        // Belt-driven supercharger: boost correlates directly with RPM
        double boostPressure = 0.0;

        if (throttle < 15.0) {
            // Closed throttle: high vacuum (engine braking)
            // At idle: -15 to -18 inHg, increases slightly with RPM
            boostPressure = -18.0 + (rpm / 1500.0);
            boostPressure = qMax(-20.0, qMin(-10.0, boostPressure));
        } else {
            // Calculate base boost from RPM (supercharger is always spinning)
            // LT4 boost curve: 2-3 PSI at 2000 RPM → 11 PSI at 6500+ RPM
            double rpmBoost = 0.0;
            if (rpm < 2000.0) {
                rpmBoost = 0.0;
            } else if (rpm < 3000.0) {
                // 2000-3000 RPM: 0 → 4 PSI
                rpmBoost = (rpm - 2000.0) / 1000.0 * 4.0;
            } else if (rpm < 5000.0) {
                // 3000-5000 RPM: 4 → 8 PSI
                rpmBoost = 4.0 + ((rpm - 3000.0) / 2000.0 * 4.0);
            } else {
                // 5000+ RPM: 8 → 11 PSI
                rpmBoost = 8.0 + ((rpm - 5000.0) / 2000.0 * 3.0);
                rpmBoost = qMin(11.0, rpmBoost);
            }

            // Throttle modulates boost (bypass valve effect)
            // At part throttle, some boost bypasses back to inlet
            double throttleFactor = (throttle - 15.0) / 85.0;  // 0 at 15%, 1.0 at 100%
            throttleFactor = qMax(0.0, qMin(1.0, throttleFactor));

            // Apply throttle factor - at closed throttle with RPM, still some vacuum
            if (throttleFactor < 0.3) {
                // Light throttle: transition from vacuum to boost
                double vacuumToBoost = throttleFactor / 0.3;
                boostPressure = (-8.0 * (1.0 - vacuumToBoost)) + (rpmBoost * vacuumToBoost);
            } else {
                // Moderate to full throttle: progressive boost
                boostPressure = rpmBoost * throttleFactor;
            }

            boostPressure = qMax(-10.0, qMin(16.0, boostPressure));
        }

        // Battery/Energy management (hybrid/electric simulation)
        // Detect braking (speed decreasing)
        bool isBraking = (speed < prevSpeed - 5.0);  // Speed dropped >5 kph
        bool isCharging = false;  // Regen braking active

        if (throttle > 80.0) {
            // Hard acceleration: DRAIN battery fast
            batteryPercent -= 0.015;  // High discharge rate
        } else if (throttle > 50.0) {
            // Moderate throttle: slower drain
            batteryPercent -= 0.005;
        } else if (isBraking && speed > 30.0) {
            // Regenerative braking: CHARGE battery (but less than drain)
            batteryPercent += 0.008;  // Moderate regen
            isCharging = true;
        } else if (throttle < 20.0 && speed > 50.0) {
            // Coasting: light regen
            batteryPercent += 0.002;
            isCharging = true;
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
        vehicleData.setBoostPressure(boostPressure);
        vehicleData.setIsCharging(isCharging);

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
