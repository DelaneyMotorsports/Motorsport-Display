/**
 * @file    App.qml
 * @brief   Main application window for Reikon Dash.
 *
 * Defines the root window containing the Reikon Dash user interface. Configured for
 * typical motorsport display hardware (1920x720 landscape) but adaptable to different
 * resolutions. Serves as the container for all dashboard screens and manages screen
 * switching logic.
 *
 * Design Philosophy:
 * - Full-screen black background for minimal distraction
 * - Hardware-optimized resolution (1920x720 for common automotive displays)
 * - Clean, minimal container - all content delegated to screen components
 *
 * Dependencies: Qt 6.x Quick, Qt 6.x Quick Window
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick
import QtQuick.Window
import "./components"

Window {
    width: 1920
    height: 720
    visible: true
    title: qsTr("Reikon Dash")

    color: "#000000"

    ScreenManager {
        anchors.fill: parent
        focus: true  // Enable keyboard input
    }
}
