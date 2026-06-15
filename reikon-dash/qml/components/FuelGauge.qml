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
        else return "#00AA00"
    }

    // Label
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: "FUEL"
        font.pixelSize: 10
        color: "#888888"
    }

    // Fuel arc
    Shape {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height - 20)
        height: width

        ShapePath {
            strokeWidth: 8
            strokeColor: root.arcColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: parent.width / 2
                centerY: parent.height / 2
                radiusX: parent.width / 2 - 10
                radiusY: parent.height / 2 - 10
                startAngle: 135
                sweepAngle: 270 * (root.fuelPercent / 100)
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 50 }
        }
    }

    // Background circle
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height - 20) - 20
        height: width
        radius: width / 2
        color: "#1a1a1a"
        border.color: "#333333"
        border.width: 1

        // Percentage text
        Text {
            anchors.centerIn: parent
            text: Math.round(root.fuelPercent) + "%"
            font.pixelSize: 24
            font.bold: true
            color: root.arcColor
        }
    }
}
