/**
 * @file    ScreenManager.qml
 * @brief   Multi-screen navigation manager.
 *
 * Manages switching between multiple dashboard screens based on user input.
 * Supports keyboard navigation (arrow keys) and touch swipe gestures.
 * Implements smooth screen transitions with fade effects.
 *
 * Properties:
 * - currentScreen: Index of active screen (0-based)
 * - screenCount: Total number of available screens
 *
 * Design Philosophy:
 * - Non-intrusive navigation (keyboard shortcuts)
 * - Smooth transitions for professional appearance
 * - Extensible for future touch/button input
 *
 * Dependencies: Qt 6.x Quick
 *
 * @author  Kevin Delaney
 * @date    January 14, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick

Item {
    id: root

    property int currentScreen: 0
    property int screenCount: 3

    // Screen container with fade transition
    Item {
        id: screenContainer
        anchors.fill: parent

        Loader {
            id: screenLoader
            anchors.fill: parent
            source: getScreenSource()

            function getScreenSource() {
                switch (root.currentScreen) {
                    case 0: return "../screens/Screen01.ui.qml";
                    case 1: return "../screens/Screen02.ui.qml";
                    case 2: return "../screens/Screen03.ui.qml";
                    default: return "../screens/Screen01.ui.qml";
                }
            }

            opacity: 1.0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // Keyboard navigation
    focus: true
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Right || event.key === Qt.Key_PageDown) {
            nextScreen();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_PageUp) {
            previousScreen();
            event.accepted = true;
        } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
            let screenIndex = event.key - Qt.Key_1;
            if (screenIndex < root.screenCount) {
                switchToScreen(screenIndex);
            }
            event.accepted = true;
        }
    }

    // Touch swipe detection
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        property real startX: 0
        property real startY: 0

        onPressed: (mouse) => {
            startX = mouse.x;
            startY = mouse.y;
        }

        onReleased: (mouse) => {
            let deltaX = mouse.x - startX;
            let deltaY = mouse.y - startY;

            // Horizontal swipe detection (require >100px movement)
            if (Math.abs(deltaX) > 100 && Math.abs(deltaX) > Math.abs(deltaY)) {
                if (deltaX > 0) {
                    previousScreen();
                } else {
                    nextScreen();
                }
            }
        }
    }

    // Screen indicator dots (bottom center)
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 10

        Repeater {
            model: root.screenCount

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: index === root.currentScreen ? "#ffffff" : "#555555"
                border.color: "#888888"
                border.width: 1

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }
    }

    // Navigation functions
    function nextScreen() {
        screenLoader.opacity = 0;
        fadeTimer.screen = (root.currentScreen + 1) % root.screenCount;
        fadeTimer.start();
    }

    function previousScreen() {
        screenLoader.opacity = 0;
        fadeTimer.screen = (root.currentScreen - 1 + root.screenCount) % root.screenCount;
        fadeTimer.start();
    }

    function switchToScreen(index) {
        if (index !== root.currentScreen && index >= 0 && index < root.screenCount) {
            screenLoader.opacity = 0;
            fadeTimer.screen = index;
            fadeTimer.start();
        }
    }

    // Fade transition timer
    Timer {
        id: fadeTimer
        interval: 200
        property int screen: 0

        onTriggered: {
            root.currentScreen = screen;
            screenLoader.opacity = 1.0;
        }
    }
}
