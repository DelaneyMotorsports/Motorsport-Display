/**
 * @file    LapTimerPanel.qml
 * @brief   Lap time display with predicted, actual, and diff times.
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick

Column {
    id: root

    property int predictedTime: 0  // milliseconds
    property int actualTime: 0     // milliseconds
    property int diffTime: 0       // milliseconds

    spacing: 8

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "LAP TIMES"
        font.pixelSize: 11
        font.bold: true
        color: "#00BFFF"
        style: Text.Outline
        styleColor: "#000000"
    }

    // Predicted time
    Rectangle {
        width: parent.width
        height: 24
        color: "#0a0a0a"
        border.color: "#333333"
        border.width: 1
        radius: 2

        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 10

            Text {
                text: "PREDICTED"
                font.pixelSize: 10
                font.bold: true
                color: "#888888"
                anchors.verticalCenter: parent.verticalCenter
                width: 70
            }
            Text {
                text: formatTime(root.predictedTime)
                font.pixelSize: 13
                font.family: "monospace"
                font.bold: true
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                style: Text.Outline
                styleColor: "#000000"
            }
        }
    }

    // Actual time
    Rectangle {
        width: parent.width
        height: 24
        color: "#0a0a0a"
        border.color: "#333333"
        border.width: 1
        radius: 2

        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 10

            Text {
                text: "ACTUAL"
                font.pixelSize: 10
                font.bold: true
                color: "#888888"
                anchors.verticalCenter: parent.verticalCenter
                width: 70
            }
            Text {
                text: formatTime(root.actualTime)
                font.pixelSize: 13
                font.family: "monospace"
                font.bold: true
                color: "#00BFFF"
                anchors.verticalCenter: parent.verticalCenter
                style: Text.Outline
                styleColor: "#000000"
            }
        }
    }

    // Diff time
    Rectangle {
        width: parent.width
        height: 28
        color: "#0a0a0a"
        border.color: root.diffTime >= 0 ? "#00AA00" : "#AA0000"
        border.width: 2
        radius: 2

        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 10

            Text {
                text: "DIFF"
                font.pixelSize: 11
                font.bold: true
                color: "#AAAAAA"
                anchors.verticalCenter: parent.verticalCenter
                width: 70
            }
            Text {
                text: formatDiff(root.diffTime)
                font.pixelSize: 14
                font.family: "monospace"
                font.bold: true
                color: root.diffTime >= 0 ? "#00FF00" : "#FF4444"
                anchors.verticalCenter: parent.verticalCenter
                style: Text.Outline
                styleColor: "#000000"
            }
        }
    }

    function formatTime(ms) {
        if (ms === 0) return "00:00:00"
        var totalSeconds = Math.floor(ms / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        var centiseconds = Math.floor((ms % 1000) / 10)
        return pad(minutes, 2) + ":" + pad(seconds, 2) + ":" + pad(centiseconds, 2)
    }

    function formatDiff(ms) {
        var sign = ms >= 0 ? "+" : "-"
        return sign + formatTime(Math.abs(ms))
    }

    function pad(num, size) {
        var s = "00" + num
        return s.substr(s.length - size)
    }
}
