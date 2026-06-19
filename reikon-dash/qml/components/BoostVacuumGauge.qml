/**
 * @file    BoostVacuumGauge.qml
 * @brief   Boost/Vacuum gauge for supercharged engines.
 *
 * Displays manifold pressure for forced induction engines:
 * - Vacuum: -20 to 0 inHg (engine braking, cruise)
 * - Atmospheric: 0 (neutral throttle)
 * - Boost: 0 to 16 PSI (under load)
 *
 * Calibrated for LT4 supercharged V8 (2.4L Eaton TVS):
 * - Normal vacuum: -15 to -18 inHg
 * - Peak boost: 11 PSI (factory)
 * - Gauge max: 16 PSI (headroom)
 *
 * @author  Kevin Delaney
 * @date    June 16, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick

Item {
    id: root

    property double pressure: 0.0  // PSI (positive = boost, negative = vacuum in inHg)
    property double maxBoost: 16.0   // PSI
    property double maxVacuum: -20.0 // inHg

    width: 300
    height: 80

    // Label
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "BOOST"
        font.pixelSize: 11
        font.bold: true
        color: "#00BFFF"
        style: Text.Outline
        styleColor: "#000000"
    }

    // Gauge container
    Rectangle {
        id: gaugeContainer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#0a0a0a"
        border.color: "#444444"
        border.width: 2
        radius: 4

        // Center line (atmospheric pressure)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            color: "#666666"
        }

        // Vacuum side (left, blue)
        Rectangle {
            id: vacuumBar
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 2
            height: parent.height - 4
            // Width from center to left based on vacuum
            width: root.pressure < 0 ?
                   (parent.width / 2 - 2) * (Math.abs(root.pressure) / Math.abs(root.maxVacuum)) : 0
            color: "#00BFFF"
            opacity: 0.7
            radius: 2
            transformOrigin: Item.Right
            x: parent.width / 2 - width

            Behavior on width {
                NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
            }
        }

        // Boost side (right, red/yellow gradient)
        Rectangle {
            id: boostBar
            anchors.left: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 2
            height: parent.height - 4
            width: root.pressure > 0 ?
                   (parent.width / 2 - 2) * (root.pressure / root.maxBoost) : 0

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#FFD700" }  // Gold at low boost
                GradientStop { position: 0.6; color: "#FFA500" }  // Orange
                GradientStop { position: 1.0; color: "#FF4444" }  // Red at high boost
            }
            radius: 2

            Behavior on width {
                NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
            }
        }

        // Digital readout
        Text {
            anchors.centerIn: parent
            text: {
                if (root.pressure > 0.1) {
                    return "+" + root.pressure.toFixed(1) + " PSI"
                } else if (root.pressure < -0.5) {
                    return root.pressure.toFixed(1) + " inHg"
                } else {
                    return "0.0"
                }
            }
            font.pixelSize: 18
            font.bold: true
            font.family: "monospace"
            color: root.pressure > 8 ? "#FF4444" : "#FFFFFF"
            style: Text.Outline
            styleColor: "#000000"
        }

        // Vacuum scale markers (left side)
        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 4
            spacing: parent.width / 2 / 5

            Repeater {
                model: ["-20", "-15", "-10", "-5", "0"]
                Text {
                    text: modelData
                    font.pixelSize: 8
                    color: "#666666"
                }
            }
        }

        // Boost scale markers (right side)
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 4
            spacing: parent.width / 2 / 4

            Repeater {
                model: ["4", "8", "12", "16"]
                Text {
                    text: modelData
                    font.pixelSize: 8
                    color: "#888888"
                }
            }
        }
    }
}
