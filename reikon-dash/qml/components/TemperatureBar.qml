/**
 * @file    TemperatureBar.qml
 * @brief   Horizontal temperature bar with gradient and C/H markers.
 *
 * Displays temperature as a horizontal bar graph with:
 * - Cold to Hot gradient coloring
 * - C and H markers at ends
 * - Warning colors when temperature is high
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick

Item {
    id: root

    // Public properties
    property real temperature: 70  // Celsius
    property real minTemp: 0
    property real maxTemp: 120
    property string label: "COOLANT"
    property color normalColor: "#00AA00"
    property color warningColor: "#FF6600"
    property color dangerColor: "#FF0000"

    // Calculated
    property real progress: Math.max(0, Math.min(1, (temperature - minTemp) / (maxTemp - minTemp)))
    property color barColor: {
        if (progress > 0.85) return dangerColor
        else if (progress > 0.70) return warningColor
        else return normalColor
    }

    // Label
    Text {
        id: labelText
        anchors.left: parent.left
        anchors.top: parent.top
        text: root.label
        font.pixelSize: 10
        color: "#888888"
    }

    // Bar container
    Rectangle {
        id: barContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: labelText.bottom
        anchors.topMargin: 4
        height: 20
        color: "#0a0a0a"
        border.color: "#444444"
        border.width: 1
        radius: 3

        // Inner shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 2
            color: "transparent"

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#33000000" }
                GradientStop { position: 0.3; color: "transparent" }
            }
        }

        // Filled portion with gradient
        Rectangle {
            id: filledBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: (parent.width - 4) * root.progress
            radius: 2

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: root.progress > 0.70 ? root.barColor : "#00BFFF"  // Cyan when cool
                }
                GradientStop {
                    position: 1.0
                    color: root.barColor
                }
            }

            // Glow effect when hot
            layer.enabled: root.progress > 0.85
            layer.effect: ShaderEffect {
                property color glowColor: root.barColor
                fragmentShader: "
                    varying highp vec2 qt_TexCoord0;
                    uniform lowp vec4 glowColor;
                    uniform lowp float qt_Opacity;
                    void main() {
                        gl_FragColor = glowColor * 0.5 * qt_Opacity;
                    }
                "
            }

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        // C marker
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 6
            text: "C"
            font.pixelSize: 10
            font.bold: true
            color: "#00BFFF"
            style: Text.Outline
            styleColor: "#000000"
        }

        // H marker
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 6
            text: "H"
            font.pixelSize: 10
            font.bold: true
            color: "#FF4444"
            style: Text.Outline
            styleColor: "#000000"
        }
    }
}
