/**
 * @file    DigitalGear.qml
 * @brief   Digital gear position display component.
 *
 * Large, high-contrast numerical display for current gear selection.
 * Designed for racing visibility with automatic neutral/reverse detection.
 *
 * Properties:
 * - gear: Current gear (0=N, -1=R, 1-6=forward gears)
 *
 * Design Philosophy:
 * - Maximum readability at racing speeds
 * - Color coding: red for reverse, blue for neutral, white for forward
 * - Large font optimized for 1920x720 resolution
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

    width: 200
    height: 200
    radius: 12

    property int gear: 0
    property color gearColor: {
        if (gear === -1) return "#FF4444"  // Red for reverse
        if (gear === 0) return "#00BFFF"   // Cyan for neutral
        return "#FFFFFF"                    // White for forward gears
    }

    // Gradient background
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#55000000" }
        GradientStop { position: 0.7; color: "#FF0a0a0a" }
        GradientStop { position: 1.0; color: "#000000" }
    }

    border.color: gearColor
    border.width: 3

    // Inner highlight
    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: 9
        color: "transparent"

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#22FFFFFF" }
            GradientStop { position: 0.3; color: "transparent" }
        }
    }

    Text {
        id: gearText
        anchors.centerIn: parent
        text: {
            if (root.gear === 0) return "N"
            if (root.gear === -1) return "R"
            return root.gear.toString()
        }
        font.pixelSize: 140
        font.bold: true
        color: gearColor
        style: Text.Outline
        styleColor: "#000000"

        // Smooth color transition
        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }

    // Subtle pulse on gear change
    SequentialAnimation {
        id: gearChangeAnim
        running: false

        NumberAnimation {
            target: root
            property: "scale"
            to: 1.1
            duration: 100
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    onGearChanged: gearChangeAnim.restart()
}
