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

    // Scale factor based on parent width
    property real scaleFactor: Math.max(1.0, width / 200.0)

    spacing: 8 * scaleFactor

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "LAP TIMES"
        font.pixelSize: Math.max(11, 11 * root.scaleFactor)
        font.bold: true
        color: "#00BFFF"
        style: Text.Outline
        styleColor: "#000000"
    }

    // Predicted time
    Rectangle {
        width: parent.width
        height: 24 * root.scaleFactor
        color: "#0a0a0a"
        border.color: "#333333"
        border.width: 1 * root.scaleFactor
        radius: 2 * root.scaleFactor

        Row {
            anchors.fill: parent
            anchors.margins: 4 * root.scaleFactor
            spacing: 10 * root.scaleFactor

            Text {
                text: "PREDICTED"
                font.pixelSize: Math.max(10, 10 * root.scaleFactor)
                font.bold: true
                color: "#888888"
                anchors.verticalCenter: parent.verticalCenter
                width: 70 * root.scaleFactor
            }
            Text {
                text: formatTime(root.predictedTime)
                font.pixelSize: Math.max(13, 13 * root.scaleFactor)
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
        height: 24 * root.scaleFactor
        color: "#0a0a0a"
        border.color: "#333333"
        border.width: 1 * root.scaleFactor
        radius: 2 * root.scaleFactor

        Row {
            anchors.fill: parent
            anchors.margins: 4 * root.scaleFactor
            spacing: 10 * root.scaleFactor

            Text {
                text: "ACTUAL"
                font.pixelSize: Math.max(10, 10 * root.scaleFactor)
                font.bold: true
                color: "#888888"
                anchors.verticalCenter: parent.verticalCenter
                width: 70 * root.scaleFactor
            }
            Text {
                text: formatTime(root.actualTime)
                font.pixelSize: Math.max(13, 13 * root.scaleFactor)
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
        height: 28 * root.scaleFactor
        color: "#0a0a0a"
        border.color: root.diffTime >= 0 ? "#00AA00" : "#AA0000"
        border.width: 2 * root.scaleFactor
        radius: 2 * root.scaleFactor

        Row {
            anchors.fill: parent
            anchors.margins: 4 * root.scaleFactor
            spacing: 10 * root.scaleFactor

            Text {
                text: "DIFF"
                font.pixelSize: Math.max(11, 11 * root.scaleFactor)
                font.bold: true
                color: "#AAAAAA"
                anchors.verticalCenter: parent.verticalCenter
                width: 70 * root.scaleFactor
            }
            Text {
                text: formatDiff(root.diffTime)
                font.pixelSize: Math.max(14, 14 * root.scaleFactor)
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
