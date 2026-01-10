/**
 * @file    ShiftLight.qml
 * @brief   Visual shift point indicator for optimal gear changes.
 *
 * Implements an animated shift light that activates when the engine reaches the optimal
 * shift RPM. Features a pulsing animation to grab driver attention during high-speed
 * racing conditions. Color changes from dark gray (inactive) to bright red (active)
 * with opacity pulsing for maximum visibility.
 *
 * Properties:
 * - active: Controls shift light state (bind to RPM threshold logic)
 *
 * Design Philosophy:
 * - High-contrast colors for racing visibility
 * - Attention-grabbing pulse animation (200ms cycle)
 * - Rounded corners for modern aesthetic
 * - Simple boolean control for easy integration
 *
 * Dependencies: Qt 6.x Quick
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick

Rectangle {
    id: root

    width: 200
    height: 50
    color: active ? "#ff0000" : "#333333"
    radius: 5

    property bool active: false

    SequentialAnimation on opacity {
        running: root.active
        loops: Animation.Infinite

        NumberAnimation { to: 0.3; duration: 200 }
        NumberAnimation { to: 1.0; duration: 200 }
    }
}
