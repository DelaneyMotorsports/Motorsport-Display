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
    color: "#000000"
    border.color: "#333333"
    border.width: 2
    radius: 10

    property int gear: 0

    Text {
        anchors.centerIn: parent
        text: {
            if (root.gear === 0) return "N";
            if (root.gear === -1) return "R";
            return root.gear.toString();
        }
        font.pixelSize: 120
        font.bold: true
        color: {
            if (root.gear === -1) return "#ff0000";  // Red for reverse
            if (root.gear === 0) return "#0099ff";   // Blue for neutral
            return "#ffffff";                        // White for forward gears
        }
        style: Text.Outline
        styleColor: "#000000"
    }
}
