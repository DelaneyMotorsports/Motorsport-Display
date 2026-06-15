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

            property bool isActive: index < root.activeLEDs

            // Gradient for depth
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: isActive ? Qt.lighter(root.activeColor, 1.5) : "#2a2a2a"
                }
                GradientStop {
                    position: 0.5
                    color: isActive ? root.activeColor : "#1a1a1a"
                }
                GradientStop {
                    position: 1.0
                    color: isActive ? Qt.darker(root.activeColor, 1.2) : "#0a0a0a"
                }
            }

            border.color: isActive ? Qt.lighter(root.activeColor, 1.4) : "#333333"
            border.width: isActive ? 2 : 1

            // Inner highlight
            Rectangle {
                anchors.centerIn: parent
                width: 4
                height: 4
                radius: 2
                color: isActive ? "#FFFFFF" : "transparent"
                opacity: 0.6
            }

            Behavior on opacity {
                NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
            }
        }
    }
}
