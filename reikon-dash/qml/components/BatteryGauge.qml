/**
 * @file    BatteryGauge.qml
 * @brief   Modern battery gauge with charging indicator.
 *
 * Smartphone-style battery icon familiar to millennials:
 * - Vertical battery shape with terminal
 * - Fill level from bottom to top
 * - Color coding: Green → Yellow → Red
 * - Lightning bolt when charging (regen braking)
 *
 * @author  Kevin Delaney
 * @date    June 16, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property double batteryPercent: 84.0  // 0-100
    property bool isCharging: false  // Regen braking active

    width: 120
    height: 180

    // Battery color based on charge level
    property color batteryColor: {
        if (batteryPercent > 50) return "#00FF00"  // Green
        else if (batteryPercent > 25) return "#FFD700"  // Yellow/Gold
        else return "#FF4444"  // Red
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        // Label
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "BATTERY"
            font.pixelSize: 11
            font.bold: true
            color: "#00BFFF"
            style: Text.Outline
            styleColor: "#000000"
        }

        Item { height: 8 }

        // Battery icon container
        Item {
            width: 80
            height: 120
            anchors.horizontalCenter: parent.horizontalCenter

            // Battery terminal (top bump)
            Rectangle {
                id: terminal
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 24
                height: 6
                radius: 3
                color: "#444444"
                border.color: "#666666"
                border.width: 1
            }

            // Battery body
            Rectangle {
                id: batteryBody
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: terminal.bottom
                anchors.topMargin: 2
                width: parent.width
                height: parent.height - terminal.height - 2
                radius: 6
                color: "#0a0a0a"
                border.color: "#555555"
                border.width: 3

                // Inner glow border
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: 4
                    color: "transparent"
                    border.color: root.batteryColor
                    border.width: 1
                    opacity: 0.4
                }

                // Battery fill (bottom to top)
                Rectangle {
                    id: batteryFill
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 5
                    height: (parent.height - 10) * (root.batteryPercent / 100.0)
                    radius: 3

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(root.batteryColor, 1.3) }
                        GradientStop { position: 0.5; color: root.batteryColor }
                        GradientStop { position: 1.0; color: Qt.darker(root.batteryColor, 1.2) }
                    }

                    Behavior on height {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                // Percentage text
                Text {
                    anchors.centerIn: parent
                    text: Math.round(root.batteryPercent) + "%"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#FFFFFF"
                    style: Text.Outline
                    styleColor: "#000000"
                }

                // Lightning bolt (charging indicator)
                Shape {
                    anchors.centerIn: parent
                    width: 30
                    height: 40
                    visible: root.isCharging
                    opacity: root.isCharging ? 1.0 : 0.0

                    layer.enabled: true
                    layer.smooth: true

                    ShapePath {
                        strokeColor: "transparent"
                        fillColor: "#FFD700"

                        // Lightning bolt shape
                        PathSvg {
                            path: "M15,0 L8,20 L18,20 L12,40 L25,15 L15,15 Z"
                        }
                    }

                    // Pulse animation when charging
                    SequentialAnimation on opacity {
                        running: root.isCharging
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.5; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                }
            }
        }

        Item { height: 8 }

        // Status text
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.isCharging ? "REGEN" : (root.batteryPercent < 20 ? "LOW" : "")
            font.pixelSize: 10
            font.bold: true
            color: root.isCharging ? "#FFD700" : "#FF4444"
            style: Text.Outline
            styleColor: "#000000"
            visible: root.isCharging || root.batteryPercent < 20
        }
    }
}
