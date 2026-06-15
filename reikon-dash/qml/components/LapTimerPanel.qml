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
        font.pixelSize: 10
        color: "#888888"
    }

    // Predicted time
    Row {
        spacing: 10
        Text {
            text: "PREDICTED"
            font.pixelSize: 10
            color: "#666666"
            width: 70
        }
        Text {
            text: formatTime(root.predictedTime)
            font.pixelSize: 12
            font.family: "monospace"
            color: "#FFFFFF"
        }
    }

    // Actual time
    Row {
        spacing: 10
        Text {
            text: "ACTUAL"
            font.pixelSize: 10
            color: "#666666"
            width: 70
        }
        Text {
            text: formatTime(root.actualTime)
            font.pixelSize: 12
            font.family: "monospace"
            color: "#FFFFFF"
        }
    }

    // Diff time
    Row {
        spacing: 10
        Text {
            text: "DIFF"
            font.pixelSize: 10
            color: "#666666"
            width: 70
        }
        Text {
            text: formatDiff(root.diffTime)
            font.pixelSize: 12
            font.family: "monospace"
            color: root.diffTime >= 0 ? "#00FF00" : "#FF0000"
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
