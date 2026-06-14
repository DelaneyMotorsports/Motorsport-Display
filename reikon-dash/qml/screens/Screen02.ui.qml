/**
 * @file    Screen02.ui.qml
 * @brief   Minimal high-speed racing screen.
 *
 * Simplified dashboard for maximum concentration during racing.
 * Shows only critical information: RPM, gear, speed, shift light.
 * Large elements optimized for peripheral vision at high speeds.
 *
 * Design Philosophy:
 * - Minimal distraction
 * - Large, readable elements
 * - High contrast for visibility
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
import "../components"

Rectangle {
    id: root
    color: "#000000"

    property real currentRPM: 0
    property real currentSpeed: 0
    property int currentGear: 0

    // Full-width shift light
    ShiftLight {
        id: shiftLight
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        width: 600
        height: 80
    }

    // Center: Massive gear display
    DigitalGear {
        id: gearDisplay
        anchors.centerIn: parent
        width: 400
        height: 400
    }

    // Left: RPM bar gauge (vertical)
    Rectangle {
        id: rpmBar
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 100
        width: 60
        height: 500
        color: "#222222"
        border.color: "#555555"
        border.width: 2
        radius: 5

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 5
            width: parent.width - 10
            height: Math.max(0, (root.currentRPM / 8000.0) * (parent.height - 10))
            color: {
                if (root.currentRPM < 6000) return "#00ff00";
                if (root.currentRPM < 7000) return "#ffaa00";
                return "#ff0000";
            }
            radius: 3

            Behavior on height {
                NumberAnimation { duration: 50 }
            }
        }

        Text {
            anchors.bottom: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
            text: Math.round(root.currentRPM).toString()
            font.pixelSize: 36
            font.bold: true
            color: "#ffffff"
        }
    }

    // Right: Speed display
    Column {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 100
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.currentSpeed).toString()
            font.pixelSize: 120
            font.bold: true
            color: "#00aaff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "km/h"
            font.pixelSize: 28
            color: "#aaaaaa"
        }
    }

    // Signal bindings
    Connections {
        target: signalBus

        function onSignalChanged(signalName, value) {
            switch (signalName) {
                case "EngineRPM":
                    root.currentRPM = value;
                    shiftLight.active = (value >= 7000);
                    break;
                case "VehicleSpeed":
                    root.currentSpeed = value;
                    break;
                case "Gear":
                    root.currentGear = value;
                    gearDisplay.gear = value;
                    break;
            }
        }
    }
}
