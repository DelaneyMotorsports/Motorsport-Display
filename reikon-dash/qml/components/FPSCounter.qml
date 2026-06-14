/**
 * @file    FPSCounter.qml
 * @brief   Development FPS monitoring overlay.
 *
 * Displays real-time frame rate for performance validation on target hardware.
 * Should be disabled in production builds.
 *
 * Design Philosophy:
 * - Non-intrusive overlay
 * - Accurate frame timing
 * - Color-coded performance indicators
 *
 * Dependencies: Qt 6.x Quick
 *
 * @author  Kevin Delaney
 * @date    January 14, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick

Rectangle {
    id: root
    width: 120
    height: 50
    color: "#80000000"
    border.color: "#ffffff"
    border.width: 1
    radius: 5

    property int frameCount: 0
    property real fps: 0

    Text {
        anchors.centerIn: parent
        text: "FPS: " + root.fps.toFixed(1)
        font.pixelSize: 18
        font.bold: true
        color: {
            if (root.fps >= 55) return "#00ff00";  // Green: Good
            if (root.fps >= 30) return "#ffaa00";  // Orange: Acceptable
            return "#ff0000";                      // Red: Poor
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.fps = root.frameCount;
            root.frameCount = 0;
        }
    }

    NumberAnimation on frameCount {
        from: frameCount
        to: frameCount + 1
        duration: 1
        running: true
        loops: Animation.Infinite
    }
}
