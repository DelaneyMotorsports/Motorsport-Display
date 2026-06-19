/**
 * @file    BoostVacuumGauge.qml
 * @brief   Circular boost/vacuum dial gauge for supercharged engines.
 *
 * Displays manifold pressure as circular dial:
 * - Vacuum: -20 to 0 inHg (left half, blue)
 * - Atmospheric: 0 (top center)
 * - Boost: 0 to 16 PSI (right half, red/orange)
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
import QtQuick.Shapes

Item {
    id: root

    property double pressure: 0.0  // PSI (positive = boost, negative = vacuum in inHg)
    property double maxBoost: 16.0   // PSI
    property double maxVacuum: -20.0 // inHg

    width: 140
    height: 140

    // Calculate needle angle: -90° (max vacuum) to +90° (max boost)
    property double needleAngle: {
        if (pressure < 0) {
            // Vacuum: map -20 to 0 inHg → -90° to 0°
            return -90 + (90 * (1 + pressure / maxVacuum))
        } else {
            // Boost: map 0 to 16 PSI → 0° to 90°
            return 90 * (pressure / maxBoost)
        }
    }

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

    // Circular dial container
    Item {
        id: dialContainer
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 8
        width: 100
        height: 100

        // Background arc (full 180° sweep)
        Shape {
            anchors.fill: parent
            ShapePath {
                strokeColor: "#333333"
                strokeWidth: 12
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dialContainer.width / 2
                    centerY: dialContainer.height / 2
                    radiusX: 40
                    radiusY: 40
                    startAngle: -180
                    sweepAngle: 180
                }
            }
        }

        // Vacuum arc (left half, blue)
        Shape {
            anchors.fill: parent
            visible: root.pressure < 0

            ShapePath {
                strokeColor: "#00BFFF"
                strokeWidth: 10
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dialContainer.width / 2
                    centerY: dialContainer.height / 2
                    radiusX: 40
                    radiusY: 40
                    startAngle: -180
                    sweepAngle: 90 * (1 + root.pressure / root.maxVacuum)
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }

        // Boost arc (right half, gradient via colored sections)
        Shape {
            anchors.fill: parent
            visible: root.pressure > 0

            ShapePath {
                strokeColor: {
                    if (root.pressure < 4) return "#FFD700"      // Gold
                    else if (root.pressure < 10) return "#FFA500" // Orange
                    else return "#FF4444"                         // Red
                }
                strokeWidth: 10
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dialContainer.width / 2
                    centerY: dialContainer.height / 2
                    radiusX: 40
                    radiusY: 40
                    startAngle: -90
                    sweepAngle: 90 * (root.pressure / root.maxBoost)
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }

        // Center pivot point
        Rectangle {
            anchors.centerIn: parent
            width: 6
            height: 6
            radius: 3
            color: "#FFFFFF"
            border.color: "#000000"
            border.width: 1
        }

        // Needle
        Rectangle {
            id: needle
            width: 35
            height: 2
            color: "#FFFFFF"
            x: dialContainer.width / 2
            y: dialContainer.height / 2 - height / 2
            transformOrigin: Item.Left
            rotation: root.needleAngle

            Behavior on rotation {
                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
            }

            // Needle tip
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 4
                radius: 2
                color: "#FF0000"
            }
        }

        // Scale markers
        Repeater {
            model: [
                { angle: -180, label: "20" },
                { angle: -135, label: "10" },
                { angle: -90, label: "0" },
                { angle: -45, label: "8" },
                { angle: 0, label: "16" }
            ]

            Text {
                x: dialContainer.width / 2 + Math.cos((modelData.angle - 90) * Math.PI / 180) * 52 - width / 2
                y: dialContainer.height / 2 + Math.sin((modelData.angle - 90) * Math.PI / 180) * 52 - height / 2
                text: modelData.label
                font.pixelSize: 8
                font.bold: true
                color: "#888888"
            }
        }
    }

    // Digital readout
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        text: {
            if (root.pressure > 0.1) {
                return "+" + root.pressure.toFixed(1) + " PSI"
            } else if (root.pressure < -0.5) {
                return root.pressure.toFixed(1) + " inHg"
            } else {
                return "0.0"
            }
        }
        font.pixelSize: 12
        font.bold: true
        font.family: "monospace"
        color: root.pressure > 8 ? "#FF4444" : "#FFFFFF"
        style: Text.Outline
        styleColor: "#000000"
    }
}
