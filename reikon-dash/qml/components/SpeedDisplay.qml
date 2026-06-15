/**
 * @file    SpeedDisplay.qml
 * @brief   Large digital speed readout.
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick

Column {
    id: root

    property real speed: 0
    property string units: "kph"

    spacing: 5

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "SPEED"
        font.pixelSize: 10
        color: "#888888"
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Math.round(root.speed)
        font.pixelSize: 48
        font.bold: true
        color: "#FFFFFF"
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.units
        font.pixelSize: 14
        color: "#AAAAAA"
    }
}
