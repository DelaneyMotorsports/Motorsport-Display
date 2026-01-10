/**
 * @file    Screen01.ui.qml
 * @brief   Primary dashboard screen layout (Qt Design Studio compatible).
 *
 * Defines the main telemetry display screen featuring an RPM gauge and shift light.
 * This .ui.qml file is designed to be edited in Qt Design Studio for visual layout
 * work, with business logic kept in a separate Screen01.qml file if needed. The screen
 * follows a centered gauge layout with top-mounted shift indicator.
 *
 * Design Philosophy:
 * - Visual design tool compatibility (.ui.qml convention)
 * - Clean separation of layout and logic
 * - Component-based architecture for reusability
 * - High-contrast design for racing visibility
 *
 * Dependencies: Qt 6.x Quick, Qt 6.x Quick Controls
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick
import QtQuick.Controls
import "../components"

Rectangle {
    id: root
    color: "#000000"

    // Main dashboard layout
    // This file is intended to be edited in Qt Design Studio

    GaugeArc {
        id: rpmGauge
        anchors.centerIn: parent
        width: 400
        height: 400
    }

    ShiftLight {
        id: shiftLight
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
    }
}
