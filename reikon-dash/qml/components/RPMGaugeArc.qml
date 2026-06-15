/**
 * @file    RPMGaugeArc.qml
 * @brief   Large center RPM gauge with arc display and digital readout.
 *
 * Primary tachometer display featuring:
 * - Circular arc showing RPM progress
 * - Large digital RPM readout
 * - Scale markers around perimeter
 * - Color-coded zones (safe/warning/danger)
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // Public properties
    property int rpm: 0
    property int minRpm: 0
    property int maxRpm: 8000
    property color arcColor: "#FF0000"
    property color backgroundColor: "#1a1a1a"
    property int scaleMarkers: 9  // 0-8 or 0-10

    // Calculated properties
    property real rpmProgress: (rpm - minRpm) / (maxRpm - minRpm)
    property real startAngle: 135  // Start at bottom-left
    property real spanAngle: 270   // Sweep to bottom-right

    // Background circle
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        radius: width / 2
        color: root.backgroundColor
        border.color: "#333333"
        border.width: 2
    }

    // RPM arc
    Shape {
        anchors.fill: parent

        ShapePath {
            strokeWidth: 18
            strokeColor: root.arcColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (Math.min(root.width, root.height) / 2) - 25
                radiusY: (Math.min(root.width, root.height) / 2) - 25
                startAngle: root.startAngle
                sweepAngle: root.spanAngle * root.rpmProgress
            }
        }

        // Smooth arc animation
        Behavior on opacity {
            NumberAnimation { duration: 50 }
        }
    }

    // Scale markers
    Repeater {
        model: root.scaleMarkers

        Item {
            property real angle: root.startAngle + (root.spanAngle / (root.scaleMarkers - 1)) * index
            property real radian: angle * Math.PI / 180
            property real radius: (Math.min(root.width, root.height) / 2) - 15

            x: root.width / 2 + Math.cos(radian) * radius - width / 2
            y: root.height / 2 + Math.sin(radian) * radius - height / 2

            Text {
                anchors.centerIn: parent
                text: index
                font.pixelSize: 14
                font.bold: true
                color: "#888888"
            }
        }
    }

    // Digital RPM readout (center)
    Column {
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.rpm
            font.pixelSize: 72
            font.bold: true
            color: "#FFFFFF"
            style: Text.Outline
            styleColor: "#000000"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "rpm"
            font.pixelSize: 16
            color: "#AAAAAA"
        }
    }
}
