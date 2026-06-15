/**
 * @file    LEDSideIndicator.qml
 * @brief   Vertical LED indicator bar for sides of display.
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick

Column {
    id: root

    property int ledCount: 5
    property color activeColor: "#00BFFF"
    property int activeLEDs: 0  // How many LEDs are active (0-5)

    spacing: 8

    Repeater {
        model: root.ledCount

        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: index < root.activeLEDs ? root.activeColor : "#222222"
            border.color: index < root.activeLEDs ? Qt.lighter(root.activeColor, 1.3) : "#111111"
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }
    }
}
