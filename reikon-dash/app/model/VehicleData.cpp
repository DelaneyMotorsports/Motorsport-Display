/**
 * @file    VehicleData.cpp
 * @brief   Implementation of VehicleData telemetry model.
 *
 * @author  Kevin Delaney
 * @date    June 16, 2026
 * @company Delaney Motorsports, LLC
 */

#include "VehicleData.h"

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
{
    // Initialize with safe defaults
}

void VehicleData::setRpm(double rpm)
{
    if (qFuzzyCompare(m_rpm, rpm))
        return;

    m_rpm = rpm;
    emit rpmChanged();
    updateWarnings();
}

void VehicleData::setSpeed(double speed)
{
    if (qFuzzyCompare(m_speed, speed))
        return;

    m_speed = speed;
    emit speedChanged();
}

void VehicleData::setGear(int gear)
{
    if (m_gear == gear)
        return;

    m_gear = gear;
    emit gearChanged();
}

void VehicleData::setThrottle(double throttle)
{
    if (qFuzzyCompare(m_throttle, throttle))
        return;

    m_throttle = throttle;
    emit throttleChanged();
}

void VehicleData::setCoolantTemp(double temp)
{
    if (qFuzzyCompare(m_coolantTemp, temp))
        return;

    m_coolantTemp = temp;
    emit coolantTempChanged();
    updateWarnings();
}

void VehicleData::setOilTemp(double temp)
{
    if (qFuzzyCompare(m_oilTemp, temp))
        return;

    m_oilTemp = temp;
    emit oilTempChanged();
    updateWarnings();
}

void VehicleData::setOilPressure(double pressure)
{
    if (qFuzzyCompare(m_oilPressure, pressure))
        return;

    m_oilPressure = pressure;
    emit oilPressureChanged();
    updateWarnings();
}

void VehicleData::setFuelPercent(double percent)
{
    if (qFuzzyCompare(m_fuelPercent, percent))
        return;

    m_fuelPercent = percent;
    emit fuelPercentChanged();
    updateWarnings();
}

void VehicleData::setFuelPressure(double pressure)
{
    if (qFuzzyCompare(m_fuelPressure, pressure))
        return;

    m_fuelPressure = pressure;
    emit fuelPressureChanged();
}

void VehicleData::setBoostPressure(double pressure)
{
    if (qFuzzyCompare(m_boostPressure, pressure))
        return;

    m_boostPressure = pressure;
    emit boostPressureChanged();
}

void VehicleData::setLapTimePredicted(int ms)
{
    if (m_lapTimePredicted == ms)
        return;

    m_lapTimePredicted = ms;
    emit lapTimePredictedChanged();

    // Update diff when predicted changes
    m_lapTimeDiff = m_lapTimeActual - m_lapTimePredicted;
    emit lapTimeDiffChanged();
}

void VehicleData::setLapTimeActual(int ms)
{
    if (m_lapTimeActual == ms)
        return;

    m_lapTimeActual = ms;
    emit lapTimeActualChanged();

    // Update diff when actual changes
    m_lapTimeDiff = m_lapTimeActual - m_lapTimePredicted;
    emit lapTimeDiffChanged();
}

void VehicleData::setLapTimeDiff(int ms)
{
    if (m_lapTimeDiff == ms)
        return;

    m_lapTimeDiff = ms;
    emit lapTimeDiffChanged();
}

void VehicleData::setIsCharging(bool charging)
{
    if (m_isCharging == charging)
        return;

    m_isCharging = charging;
    emit isChargingChanged();
}

void VehicleData::updateWarnings()
{
    // Oil warning: high temp OR low pressure
    bool newWarningOil = (m_oilTemp > 130.0) || (m_oilPressure < 2.0);
    if (m_warningOil != newWarningOil) {
        m_warningOil = newWarningOil;
        emit warningOilChanged();
    }

    // Coolant warning: high temp
    bool newWarningCoolant = (m_coolantTemp > 105.0);
    if (m_warningCoolant != newWarningCoolant) {
        m_warningCoolant = newWarningCoolant;
        emit warningCoolantChanged();
    }

    // Fuel warning: low fuel
    bool newWarningFuel = (m_fuelPercent < 10.0);
    if (m_warningFuel != newWarningFuel) {
        m_warningFuel = newWarningFuel;
        emit warningFuelChanged();
    }
}
