/**
 * @file    FuelGauge.qml
 * @brief   Circular fuel gauge with percentage display.
 *
 * Compact circular gauge showing fuel level with:
 * - Percentage display
 * - Color warnings (green/yellow/red)
 * - Smooth animations
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real fuelPercent: 66  // 0-100
    property color arcColor: {
        if (fuelPercent < 10) return "#FF0000"
        else if (fuelPercent < 25) return "#FFA500"
        else return "#00BFFF"  // Cyan to match theme
    }

    // Calculated
    property real arcSize: Math.min(width, height - 20)
    property real progress: Math.max(0, Math.min(1, fuelPercent / 100))

    Behavior on progress {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    // Label
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "FUEL"
        font.pixelSize: 10
        color: "#888888"
    }

    // Background radial gradient
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 10
        width: arcSize
        height: arcSize
        radius: width / 2

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 0.7; color: "#FF1a1a1a" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    // Background arc (grey)
    Shape {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 10
        width: arcSize
        height: arcSize
        layer.enabled: true
        layer.smooth: true

        ShapePath {
            strokeWidth: arcSize * 0.08
            strokeColor: "#333333"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: arcSize / 2
                centerY: arcSize / 2
                radiusX: (arcSize / 2) - (arcSize * 0.10)
                radiusY: (arcSize / 2) - (arcSize * 0.10)
                startAngle: 135
                sweepAngle: 270
            }
        }
    }

    // Value arc (colored with smooth animation)
    Shape {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 10
        width: arcSize
        height: arcSize
        layer.enabled: true
        layer.smooth: true

        ShapePath {
            id: valueArc
            strokeWidth: arcSize * 0.08
            strokeColor: root.arcColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: arcSize / 2
                centerY: arcSize / 2
                radiusX: (arcSize / 2) - (arcSize * 0.10)
                radiusY: (arcSize / 2) - (arcSize * 0.10)
                startAngle: 135
                sweepAngle: 270 * root.progress
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    // Center circle background
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 10
        width: arcSize * 0.60
        height: width
        radius: width / 2
        color: "#1a1a1a"
        border.color: "#444444"
        border.width: 1

        // Percentage text
        Text {
            anchors.centerIn: parent
            text: Math.round(root.fuelPercent) + "%"
            font.pixelSize: arcSize * 0.20
            font.bold: true
            color: root.arcColor
            style: Text.Outline
            styleColor: "#000000"
        }
    }
}
