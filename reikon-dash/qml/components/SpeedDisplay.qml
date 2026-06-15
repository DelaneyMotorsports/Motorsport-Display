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
        font.pixelSize: 11
        font.bold: true
        color: "#00BFFF"
        style: Text.Outline
        styleColor: "#000000"
    }

    // Background box for speed number
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: speedText.width + 20
        height: speedText.height + 10
        color: "#1a1a1a"
        border.color: "#00BFFF"
        border.width: 2
        radius: 4

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#33000000" }
            GradientStop { position: 1.0; color: "#FF1a1a1a" }
        }

        Text {
            id: speedText
            anchors.centerIn: parent
            text: Math.round(root.speed)
            font.pixelSize: 56
            font.bold: true
            color: "#FFFFFF"
            style: Text.Outline
            styleColor: "#000000"
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.units.toUpperCase()
        font.pixelSize: 16
        font.bold: true
        color: "#888888"
        style: Text.Outline
        styleColor: "#000000"
    }
}
