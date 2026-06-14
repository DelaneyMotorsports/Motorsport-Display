/**
 * @file    Screen03.ui.qml
 * @brief   Data-heavy telemetry screen.
 *
 * Comprehensive dashboard showing all available telemetry signals
 * in a compact grid layout. Useful for testing, data logging review,
 * and detailed vehicle monitoring.
 *
 * Design Philosophy:
 * - Maximum information density
 * - Organized grid layout
 * - Smaller gauges for space efficiency
 *
 * Dependencies: Qt 6.x Quick
 *
 * @author  Kevin Delaney
 * @date    January 14, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root
    color: "#000000"

    property real currentRPM: 0
    property real currentSpeed: 0
    property real currentCoolant: 0
    property real currentThrottle: 0
    property int currentGear: 0

    // Top row: Shift light + Gear
    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        spacing: 30

        ShiftLight {
            id: shiftLight
            width: 250
            height: 60
        }

        DigitalGear {
            id: gearDisplay
            width: 120
            height: 120
        }
    }

    // Main grid of gauges
    GridLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 40
        columns: 4
        rowSpacing: 20
        columnSpacing: 20

        // Row 1
        LabeledGauge {
            id: rpmGauge
            width: 200
            height: 200
            labelText: "RPM"
            units: "rpm"
            minValue: 0
            maxValue: 8000
            arcColor: "#00ff00"
            decimalPlaces: 0
        }

        LabeledGauge {
            id: speedGauge
            width: 200
            height: 200
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
            arcColor: "#ff9900"
            decimalPlaces: 0
        }

        LabeledGauge {
            id: throttleGauge
            width: 200
            height: 200
            labelText: "THROTTLE"
            units: "%"
            minValue: 0
            maxValue: 100
            arcColor: "#00ff00"
            decimalPlaces: 0
            value: 0  // Placeholder - not yet available
        }
    }

    // Bottom: Warning lights
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        spacing: 20

        WarningLight {
            labelText: "OIL"
            warningColor: "#ff0000"
            active: false
        }

        WarningLight {
            labelText: "H2O"
            warningColor: "#ff0000"
            active: root.currentCoolant > 105
        }

        WarningLight {
            labelText: "BAT"
            warningColor: "#ffaa00"
            active: false
        }

        WarningLight {
            labelText: "ECU"
            warningColor: "#ff9900"
            active: false
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
