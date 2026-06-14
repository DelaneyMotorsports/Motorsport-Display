/**
 * @file    WarningLight.qml
 * @brief   Generic warning light indicator component.
 *
 * Reusable warning light for various vehicle conditions (oil pressure,
 * coolant temp, battery voltage, check engine). Supports active/inactive
 * states with color customization and optional text label.
 *
 * Properties:
 * - active: Warning condition state
 * - warningColor: Color when active (default: red)
 * - labelText: Warning label/icon text
 *
 * Design Philosophy:
 * - Attention-grabbing when active
 * - Subtle when inactive
 * - Consistent sizing for dashboard layout
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

    width: 80
    height: 80
    color: active ? warningColor : "#222222"
    border.color: active ? Qt.lighter(warningColor, 1.3) : "#333333"
    border.width: 2
    radius: 5

    property bool active: false
    property color warningColor: "#ff0000"
    property string labelText: "!"

    Text {
        anchors.centerIn: parent
        text: root.labelText
        font.pixelSize: 36
        font.bold: true
        color: root.active ? "#ffffff" : "#555555"
    }

    // Pulsing animation when active
    SequentialAnimation on opacity {
        running: root.active
        loops: Animation.Infinite

        NumberAnimation { to: 0.5; duration: 400 }
        NumberAnimation { to: 1.0; duration: 400 }
    }
}
