/**
 * @file    OilPressureGauge.qml
 * @brief   Circular oil pressure dial gauge for dry sump systems.
 *
 * Displays oil pressure as circular dial:
 * - Range: 0 to 120 PSI
 * - Green zone: 40-90 PSI (normal)
 * - Yellow zone: 20-40 PSI (low warning)
 * - Red zone: <20 PSI (critical) or >100 PSI (excessive)
 *
 * Calibrated for dry sump systems (LT4, M178, VK56VD):
 * - Idle: 40-45 PSI
 * - Cruise: 60-70 PSI
 * - High RPM: 85-100 PSI
 *
 * @author  Kevin Delaney
 * @date    June 19, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property double pressure: 0.0  // PSI
    property double minPressure: 0.0
    property double maxPressure: 120.0

    // Default size (can be overridden by parent)
    width: 140
    height: 140

    // Scale factor based on actual size
    property real scaleFactor: Math.min(width, height) / 140.0

    // Calculate needle angle: -90° (0 PSI) to +90° (120 PSI)
    property double needleAngle: {
        var normalized = (pressure - minPressure) / (maxPressure - minPressure);
        normalized = Math.max(0.0, Math.min(1.0, normalized));
        return -90 + (normalized * 180);
    }

    // Pressure color based on value
    property color pressureColor: {
        if (pressure < 20) return "#FF4444"      // Critical low - Red
        else if (pressure < 40) return "#FFD700"  // Low warning - Gold
        else if (pressure > 100) return "#FFA500" // High warning - Orange
        else return "#00FF00"                     // Normal - Green
    }

    // Label
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "OIL"
        font.pixelSize: Math.max(11, 11 * root.scaleFactor)
        font.bold: true
        color: "#00BFFF"
        style: Text.Outline
        styleColor: "#000000"
    }

    // Circular dial container
    Item {
        id: dialContainer
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 8 * root.scaleFactor
        width: 100 * root.scaleFactor
        height: 100 * root.scaleFactor

        // Background arc (full 180° sweep)
        Shape {
            anchors.fill: parent
            ShapePath {
                strokeColor: "#333333"
                strokeWidth: 12 * root.scaleFactor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dialContainer.width / 2
                    centerY: dialContainer.height / 2
                    radiusX: 40 * root.scaleFactor
                    radiusY: 40 * root.scaleFactor
                    startAngle: -180
                    sweepAngle: 180
                }
            }
        }

        // Pressure arc (colored based on value)
        Shape {
            anchors.fill: parent

            ShapePath {
                strokeColor: root.pressureColor
                strokeWidth: 10 * root.scaleFactor
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: dialContainer.width / 2
                    centerY: dialContainer.height / 2
                    radiusX: 40 * root.scaleFactor
                    radiusY: 40 * root.scaleFactor
                    startAngle: -180
                    sweepAngle: 180 * ((root.pressure - root.minPressure) / (root.maxPressure - root.minPressure))
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }

        // Center pivot point
        Rectangle {
            anchors.centerIn: parent
            width: 6 * root.scaleFactor
            height: 6 * root.scaleFactor
            radius: 3 * root.scaleFactor
            color: "#FFFFFF"
            border.color: "#000000"
            border.width: 1 * root.scaleFactor
        }

        // Needle
        Rectangle {
            id: needle
            width: 35 * root.scaleFactor
            height: 2 * root.scaleFactor
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
                width: 4 * root.scaleFactor
                height: 4 * root.scaleFactor
                radius: 2 * root.scaleFactor
                color: root.pressureColor
            }
        }

        // Scale markers
        Repeater {
            model: [
                { angle: -180, label: "0" },
                { angle: -135, label: "30" },
                { angle: -90, label: "60" },
                { angle: -45, label: "90" },
                { angle: 0, label: "120" }
            ]

            Text {
                x: dialContainer.width / 2 + Math.cos((modelData.angle - 90) * Math.PI / 180) * 52 * root.scaleFactor - width / 2
                y: dialContainer.height / 2 + Math.sin((modelData.angle - 90) * Math.PI / 180) * 52 * root.scaleFactor - height / 2
                text: modelData.label
                font.pixelSize: Math.max(8, 8 * root.scaleFactor)
                font.bold: true
                color: "#888888"
            }
        }
    }

    // Digital readout
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2 * root.scaleFactor
        text: root.pressure.toFixed(0) + " PSI"
        font.pixelSize: Math.max(12, 12 * root.scaleFactor)
        font.bold: true
        font.family: "monospace"
        color: root.pressureColor
        style: Text.Outline
        styleColor: "#000000"
    }
}
