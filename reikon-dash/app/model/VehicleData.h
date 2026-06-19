/**
 * @file    VehicleData.h
 * @brief   Q_PROPERTY-based vehicle telemetry data model.
 *
 * Provides direct QML property binding for high-frequency vehicle signals.
 * Implements the Bosch DDU pattern with individual Q_PROPERTY declarations
 * for compile-time type safety and efficient QML binding.
 *
 * This class complements SignalBus by providing:
 * - Direct property access in QML (vehicleData.rpm)
 * - Compile-time type checking
 * - Optimized signal emission
 * - No string-based dispatch overhead
 *
 * Design Philosophy:
 * - High-frequency signals (RPM, Speed, Gear) use Q_PROPERTY for performance
 * - Automatic signal emission via NOTIFY
 * - MEMBER syntax for reduced boilerplate
 * - 100 Hz update capability (10ms refresh)
 *
 * Usage in QML:
 * @code
 * Tachometer {
 *     rpm: vehicleData.rpm  // Direct binding
 *     maxRpm: 8000
 * }
 * @endcode
 *
 * @author  Kevin Delaney
 * @date    June 16, 2026
 * @company Delaney Motorsports, LLC
 */

#ifndef VEHICLEDATA_H
#define VEHICLEDATA_H

#include <QObject>
#include <QVariant>

/**
 * @class VehicleData
 * @brief Real-time vehicle telemetry data container.
 *
 * Exposes motorsport telemetry as QML-bindable properties with automatic
 * change notification. Designed for 100 Hz update rates typical of
 * professional motorsport displays.
 *
 * All properties use MEMBER syntax for minimal overhead and automatic
 * signal emission when values change.
 */
class VehicleData : public QObject
{
    Q_OBJECT

    // Engine telemetry
    Q_PROPERTY(double rpm MEMBER m_rpm NOTIFY rpmChanged)
    Q_PROPERTY(double speed MEMBER m_speed NOTIFY speedChanged)
    Q_PROPERTY(int gear MEMBER m_gear NOTIFY gearChanged)
    Q_PROPERTY(double throttle MEMBER m_throttle NOTIFY throttleChanged)

    // Temperature telemetry
    Q_PROPERTY(double coolantTemp MEMBER m_coolantTemp NOTIFY coolantTempChanged)
    Q_PROPERTY(double oilTemp MEMBER m_oilTemp NOTIFY oilTempChanged)
    Q_PROPERTY(double oilPressure MEMBER m_oilPressure NOTIFY oilPressureChanged)

    // Fuel telemetry
    Q_PROPERTY(double fuelPercent MEMBER m_fuelPercent NOTIFY fuelPercentChanged)
    Q_PROPERTY(double fuelPressure MEMBER m_fuelPressure NOTIFY fuelPressureChanged)

    // Boost/Vacuum (supercharged engine)
    Q_PROPERTY(double boostPressure MEMBER m_boostPressure NOTIFY boostPressureChanged)

    // Lap timing
    Q_PROPERTY(int lapTimePredicted MEMBER m_lapTimePredicted NOTIFY lapTimePredictedChanged)
    Q_PROPERTY(int lapTimeActual MEMBER m_lapTimeActual NOTIFY lapTimeActualChanged)
    Q_PROPERTY(int lapTimeDiff MEMBER m_lapTimeDiff NOTIFY lapTimeDiffChanged)

    // Warning states
    Q_PROPERTY(bool warningOil MEMBER m_warningOil NOTIFY warningOilChanged)
    Q_PROPERTY(bool warningCoolant MEMBER m_warningCoolant NOTIFY warningCoolantChanged)
    Q_PROPERTY(bool warningFuel MEMBER m_warningFuel NOTIFY warningFuelChanged)

    // Battery charging state
    Q_PROPERTY(bool isCharging MEMBER m_isCharging NOTIFY isChargingChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);

    // Manual setters for cases where MEMBER auto-notification isn't sufficient
    void setRpm(double rpm);
    void setSpeed(double speed);
    void setGear(int gear);
    void setThrottle(double throttle);
    void setCoolantTemp(double temp);
    void setOilTemp(double temp);
    void setOilPressure(double pressure);
    void setFuelPercent(double percent);
    void setFuelPressure(double pressure);
    void setBoostPressure(double pressure);
    void setLapTimePredicted(int ms);
    void setLapTimeActual(int ms);
    void setLapTimeDiff(int ms);
    void setIsCharging(bool charging);

    // Getters (for C++ access)
    double rpm() const { return m_rpm; }
    double speed() const { return m_speed; }
    int gear() const { return m_gear; }
    double throttle() const { return m_throttle; }
    double coolantTemp() const { return m_coolantTemp; }
    double oilTemp() const { return m_oilTemp; }
    double oilPressure() const { return m_oilPressure; }
    double fuelPercent() const { return m_fuelPercent; }
    double fuelPressure() const { return m_fuelPressure; }
    double boostPressure() const { return m_boostPressure; }
    int lapTimePredicted() const { return m_lapTimePredicted; }
    int lapTimeActual() const { return m_lapTimeActual; }
    int lapTimeDiff() const { return m_lapTimeDiff; }

signals:
    // Change notifications (automatically emitted by Q_PROPERTY MEMBER)
    void rpmChanged();
    void speedChanged();
    void gearChanged();
    void throttleChanged();
    void coolantTempChanged();
    void oilTempChanged();
    void oilPressureChanged();
    void fuelPercentChanged();
    void fuelPressureChanged();
    void boostPressureChanged();
    void lapTimePredictedChanged();
    void lapTimeActualChanged();
    void lapTimeDiffChanged();
    void warningOilChanged();
    void warningCoolantChanged();
    void warningFuelChanged();
    void isChargingChanged();

private:
    // Engine telemetry
    double m_rpm = 0.0;
    double m_speed = 0.0;
    int m_gear = 1;
    double m_throttle = 0.0;

    // Temperature telemetry
    double m_coolantTemp = 70.0;
    double m_oilTemp = 80.0;
    double m_oilPressure = 4.5;

    // Fuel telemetry
    double m_fuelPercent = 84.0;
    double m_fuelPressure = 3.5;

    // Boost/Vacuum (PSI for boost, inHg for vacuum)
    double m_boostPressure = -15.0;  // Start at idle vacuum

    // Lap timing (milliseconds)
    int m_lapTimePredicted = 185250;  // 3:05.25
    int m_lapTimeActual = 187330;     // 3:07.33
    int m_lapTimeDiff = 2080;         // +2.08

    // Warning states
    bool m_warningOil = false;
    bool m_warningCoolant = false;
    bool m_warningFuel = false;

    // Battery charging state
    bool m_isCharging = false;

    // Update warning states based on telemetry
    void updateWarnings();
};

#endif // VEHICLEDATA_H
