/**
 * @file    RPMGaugeArc.qml
 * @brief   Large center RPM gauge with arc display and digital readout.
 *
 * Professional tachometer with:
 * - Circular arc with smooth gradients
 * - Large digital RPM readout
 * - Animated needle and arc
 * - Cyan/blue color scheme
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
    property int scaleMarkers: 9

    // Calculated
    property real progress: Math.max(0, Math.min(1, (rpm - minRpm) / (maxRpm - minRpm)))
    property real needleAngle: -210 + 240 * progress

    Behavior on progress {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    // Background radial gradient
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        radius: width / 2

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 0.7; color: "#FF1a1a1a" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    // Background arc (grey)
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true

        ShapePath {
            strokeWidth: root.width * 0.06
            strokeColor: "#333333"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width / 2) - (root.width * 0.08)
                radiusY: (root.height / 2) - (root.width * 0.08)
                startAngle: -210
                sweepAngle: 240
            }
        }
    }

    // Value arc (cyan with gradient)
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true

        ShapePath {
            id: valueArc
            strokeWidth: root.width * 0.06
            strokeColor: "#00BFFF"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width / 2) - (root.width * 0.08)
                radiusY: (root.height / 2) - (root.width * 0.08)
                startAngle: -210
                sweepAngle: 240 * root.progress
            }
        }
    }

    // Scale markers
    Repeater {
        model: root.scaleMarkers

        Item {
            property real angle: -210 + (240 / (root.scaleMarkers - 1)) * index
            property real radian: angle * Math.PI / 180
            property real radius: (Math.min(root.width, root.height) / 2) - (root.width * 0.02)

            x: root.width / 2 + Math.cos(radian) * radius - width / 2
            y: root.height / 2 + Math.sin(radian) * radius - height / 2

            Text {
                anchors.centerIn: parent
                text: index
                font.pixelSize: root.width * 0.035
                font.bold: true
                color: "#888888"
            }
        }
    }

    // Needle
    Rectangle {
        id: needle
        width: root.width * 0.45
        height: 2
        radius: 1
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true

        transform: Rotation {
            origin.x: 0
            origin.y: needle.height / 2
            angle: root.needleAngle

            Behavior on angle {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }
    }

    // Center hub
    Rectangle {
        width: root.width * 0.05
        height: width
        radius: width / 2
        color: "#CCCCCC"
        anchors.centerIn: parent
    }

    // Digital RPM readout
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -root.height * 0.05
        spacing: 5

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.rpm
            font.pixelSize: root.width * 0.16
            font.bold: true
            color: "#FFFFFF"
            style: Text.Outline
            styleColor: "#000000"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "rpm"
            font.pixelSize: root.width * 0.04
            color: "#BBBBBB"
        }
    }
}
