/**
 * @file    DDUScreen.qml
 * @brief   Main DDU-style motorsport HMI screen.
 *
 * Professional motorsport display layout featuring:
 * - 8-segment LED shift light bar
 * - Large center RPM gauge
 * - Temperature and fuel indicators
 * - Speed and lap time displays
 * - Side LED indicators
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick
import "../components"

Rectangle {
    id: root
    color: "#000000"

    // Direct property bindings (Bosch DDU pattern)
    // Bind directly to vehicleData Q_PROPERTY for type safety and performance
    property double rpm: vehicleData.rpm
    property int gear: vehicleData.gear
    property double speed: vehicleData.speed
    property double coolantTemp: vehicleData.coolantTemp
    property double oilTemp: vehicleData.oilTemp
    property double fuelPercent: vehicleData.fuelPercent

    // Smooth animation on all values (removes CAN signal jitter)
    // Bosch DDU uses 40-60ms smoothing on high-frequency signals
    Behavior on rpm {
        NumberAnimation { duration: 40; easing.type: Easing.OutQuad }
    }

    Behavior on speed {
        NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
    }

    Behavior on coolantTemp {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    Behavior on oilTemp {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    Behavior on fuelPercent {
        NumberAnimation { duration: 500; easing.type: Easing.OutQuad }
    }

    // Top: 8-segment LED shift light bar
    LEDShiftBar {
        id: shiftLights
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: 30
        rpm: root.rpm
        maxRpm: 10000
    }

    // Main content area
    Item {
        anchors.top: shiftLights.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.margins: 20

        // Left panel: Temperature and Fuel
        Column {
            id: leftPanel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.25
            spacing: 30

            Text {
                text: "TEMP"
                font.pixelSize: 12
                color: "#888888"
            }

            TemperatureBar {
                width: parent.width
                height: 30
                temperature: root.coolantTemp
                label: "COOLANT"
            }

            TemperatureBar {
                width: parent.width
                height: 30
                temperature: root.oilTemp
                label: "OIL"
            }

            Item { height: 20 } // Spacer

            FuelGauge {
                width: parent.width
                height: width
                fuelPercent: root.fuelPercent
            }
        }

        // Left side LEDs
        LEDSideIndicator {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: -15
            activeLEDs: Math.floor(root.rpm / 2000)  // Demo: light up based on RPM
        }

        // Center: RPM Gauge + Gear
        Item {
            id: centerPanel
            anchors.centerIn: parent
            width: parent.width * 0.40
            height: width

            RPMGaugeArc {
                anchors.fill: parent
                rpm: root.rpm
                maxRpm: 10000
                redLine: 7500
                revLimit: 8200
            }

            // Gear number overlaid
            DigitalGear {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.15
                gear: root.gear
                width: 100
                height: 100
            }
        }

        // Right panel: Lap Times and Speed
        Column {
            id: rightPanel
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.25
            spacing: 30

            LapTimerPanel {
                width: parent.width
                predictedTime: 185250  // Demo: 3:05.25
                actualTime: 187330     // Demo: 3:07.33
                diffTime: 2080         // Demo: +2.08
            }

            Item { height: 40 } // Spacer

            SpeedDisplay {
                anchors.horizontalCenter: parent.horizontalCenter
                speed: root.speed
                units: "kph"
            }
        }

        // Right side LEDs
        LEDSideIndicator {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: -15
            activeLEDs: Math.floor(root.rpm / 2000)  // Demo: sync with left
        }
    }

    // Bottom footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: "#000000"

        Row {
            anchors.fill: parent
            anchors.margins: 10

            Text {
                text: "Motorsport"
                font.pixelSize: 16
                color: "#666666"
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: parent.width - 300 } // Spacer

            Text {
                text: "REIKON DASH"
                font.pixelSize: 16
                font.bold: true
                color: "#AAAAAA"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
