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
import "./screens"

Window {
    // Use auto-detected resolution or command-line override
    width: windowWidth || 1920
    height: windowHeight || 720

    // Fullscreen mode for kiosk deployment (default)
    visibility: fullscreenMode ? Window.FullScreen : Window.Windowed

    visible: true
    title: qsTr("Reikon Dash")

    color: "#000000"

    DDUScreen {
        anchors.fill: parent
        focus: true  // Enable keyboard input
    }

    // Debug info (optional - comment out for production)
    // Text {
    //     anchors.top: parent.top
    //     anchors.right: parent.right
    //     anchors.margins: 10
    //     text: "Display: " + width + "x" + height +
    //           " (Detected: " + detectedWidth + "x" + detectedHeight + ")" +
    //           "\nMode: " + (fullscreenMode ? "Fullscreen" : "Windowed")
    //     color: "#00ff00"
    //     font.pixelSize: 12
    //     z: 1000
    // }
}
