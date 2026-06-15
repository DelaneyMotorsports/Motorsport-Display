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
        color: "#1a1a1a"
        border.color: "#333333"
        border.width: 1
        radius: 2

        // Filled portion
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: (parent.width - 4) * root.progress
            color: root.barColor
            radius: 1

            Behavior on width {
                NumberAnimation { duration: 200 }
            }
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        // C marker
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            text: "C"
            font.pixelSize: 10
            font.bold: true
            color: "#666666"
        }

        // H marker
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            text: "H"
            font.pixelSize: 10
            font.bold: true
            color: "#666666"
        }
    }
}
