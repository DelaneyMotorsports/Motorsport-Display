/**
 * @file    Screen01.ui.qml
 * @brief   Primary dashboard screen layout (Qt Design Studio compatible).
 *
 * Full-featured racing dashboard with RPM, speed, gear, coolant temp,
 * oil pressure, fuel level, and warning lights. Optimized for 1920x720
 * resolution on Raspberry Pi 5 hardware.
 *
 * Layout:
 * - Center: RPM gauge + gear display
 * - Left: Speed, coolant temp gauges
 * - Right: Fuel level gauge
 * - Top: Shift light indicator
 * - Bottom: Warning lights (oil, coolant, battery, check engine)
 *
 * Signal Bindings:
 * - EngineRPM -> RPM gauge, shift light
 * - VehicleSpeed -> Speed gauge
 * - Gear -> Gear display
 * - CoolantTemp -> Coolant gauge, warning
 *
 * Design Philosophy:
 * - Optimized for racing visibility
 * - 60 FPS smooth animation on embedded hardware
 * - GPU-accelerated rendering
 *
 * Dependencies: Qt 6.x Quick, Qt 6.x Quick Controls
 *
 * @author  Kevin Delaney
 * @date    January 14, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick
import QtQuick.Controls
import "../components"

Rectangle {
    id: root
    color: "#000000"

    // Internal state for warning thresholds
    property real currentRPM: 0
    property real currentSpeed: 0
    property real currentCoolant: 0
    property int currentGear: 0

    // Shift light at top
    ShiftLight {
        id: shiftLight
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        width: 300
        height: 60
    }

    // Center: Large RPM gauge
    GaugeArc {
        id: rpmGauge
        anchors.centerIn: parent
        width: 500
        height: 500
        minValue: 0
        maxValue: 8000
        arcColor: {
            // Color changes based on RPM range
            if (value < 6000) return "#00ff00";  // Green
            if (value < 7000) return "#ffaa00";  // Orange
            return "#ff0000";                     // Red
        }
    }

    // Center: RPM digital display
    Column {
        anchors.centerIn: rpmGauge
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.currentRPM).toString()
            font.pixelSize: 72
            font.bold: true
            color: "#ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "RPM"
            font.pixelSize: 24
            color: "#aaaaaa"
        }
    }

    // Gear display (overlaid on bottom of RPM gauge)
    DigitalGear {
        id: gearDisplay
        anchors.horizontalCenter: rpmGauge.horizontalCenter
        anchors.top: rpmGauge.bottom
        anchors.topMargin: -80
        width: 150
        height: 150
    }

    // Left side gauges (vertical layout)
    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50
        spacing: 30

        LabeledGauge {
            id: speedGauge
            width: 250
            height: 250
            labelText: "SPEED"
            units: "km/h"
            minValue: 0
            maxValue: 300
            arcColor: "#00aaff"
            decimalPlaces: 0
        }

        LabeledGauge {
            id: coolantGauge
            width: 200
            height: 200
            labelText: "COOLANT"
            units: "°C"
            minValue: 40
            maxValue: 120
            arcColor: {
                if (value < 90) return "#00ff00";   // Green - normal
                if (value < 100) return "#ffaa00";  // Orange - warm
                return "#ff0000";                   // Red - hot
            }
            decimalPlaces: 0
        }
    }

    // Right side gauge
    LabeledGauge {
        id: fuelGauge
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 50
        width: 200
        height: 200
        labelText: "FUEL"
        units: "%"
        minValue: 0
        maxValue: 100
        value: 75  // Placeholder - no fuel signal yet
        arcColor: {
            if (value > 25) return "#00ff00";   // Green
            if (value > 10) return "#ffaa00";   // Orange
            return "#ff0000";                   // Red - low fuel
        }
        decimalPlaces: 0
    }

    // Warning lights row (bottom)
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        spacing: 20

        WarningLight {
            id: oilPressureWarning
            labelText: "OIL"
            warningColor: "#ff0000"
            active: false  // Placeholder - no oil pressure signal yet
        }

        WarningLight {
            id: coolantTempWarning
            labelText: "H2O"
            warningColor: "#ff0000"
            active: root.currentCoolant > 105
        }

        WarningLight {
            id: batteryWarning
            labelText: "BAT"
            warningColor: "#ffaa00"
            active: false  // Placeholder - no battery voltage signal yet
        }

        WarningLight {
            id: checkEngineWarning
            labelText: "ECU"
            warningColor: "#ff9900"
            active: false  // Placeholder - no ECU error signal yet
        }
    }

    // Signal bindings
    Connections {
        target: signalBus

        function onSignalChanged(signalName, value) {
            switch (signalName) {
                case "EngineRPM":
                    root.currentRPM = value;
                    rpmGauge.value = value;
                    shiftLight.active = (value >= 7000);
                    break;

                case "VehicleSpeed":
                    root.currentSpeed = value;
                    speedGauge.value = value;
                    break;

                case "CoolantTemp":
                    root.currentCoolant = value;
                    coolantGauge.value = value;
                    break;

                case "Gear":
                    root.currentGear = value;
                    gearDisplay.gear = value;
                    break;
            }
        }
    }
}
