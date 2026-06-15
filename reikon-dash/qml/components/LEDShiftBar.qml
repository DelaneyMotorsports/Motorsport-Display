/**
 * @file    LEDShiftBar.qml
 * @brief   8-segment LED shift light bar for RPM indication.
 *
 * Progressive multi-segment shift light that illuminates segments
 * based on RPM threshold. Provides visual feedback for optimal
 * shift points during racing.
 *
 * @author  Kevin Delaney
 * @date    June 15, 2026
 * @company Delaney Motorsports, LLC
 */

import QtQuick

Row {
    id: root

    // Public properties
    property int rpm: 0
    property int maxRpm: 8000
    property int segmentCount: 8

    // RPM thresholds for each segment (percentage of max RPM)
    property var thresholds: [0.50, 0.60, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95]

    // Colors for progressive activation
    property var segmentColors: [
        "#00FF00",  // Green
        "#7FFF00",  // Yellow-green
        "#FFFF00",  // Yellow
        "#FFD700",  // Gold
        "#FFA500",  // Orange
        "#FF8C00",  // Dark orange
        "#FF4500",  // Red-orange
        "#FF0000"   // Red
    ]

    spacing: 4

    Repeater {
        model: root.segmentCount

        Rectangle {
            width: (root.width - (root.segmentCount - 1) * root.spacing) / root.segmentCount
            height: root.height
            radius: 3

            // Calculate if this segment should be lit
            property real threshold: root.thresholds[index]
            property bool isActive: (root.rpm / root.maxRpm) >= threshold

            color: isActive ? root.segmentColors[index] : "#1a1a1a"
            border.color: isActive ? Qt.lighter(root.segmentColors[index], 1.3) : "#333333"
            border.width: isActive ? 2 : 1

            // Gradient overlay for depth
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: isActive ? Qt.lighter(root.segmentColors[index], 1.4) : "#222222"
                }
                GradientStop {
                    position: 0.5
                    color: isActive ? root.segmentColors[index] : "#1a1a1a"
                }
                GradientStop {
                    position: 1.0
                    color: isActive ? Qt.darker(root.segmentColors[index], 1.2) : "#111111"
                }
            }

            // Inner highlight for 3D effect
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 2
                color: "transparent"
                visible: isActive

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#44FFFFFF" }
                    GradientStop { position: 0.3; color: "transparent" }
                }
            }

            // Smooth transitions
            Behavior on color {
                ColorAnimation { duration: 80; easing.type: Easing.OutQuad }
            }

            Behavior on border.width {
                NumberAnimation { duration: 80 }
            }

            // Pulse effect when active at high RPM
            SequentialAnimation on opacity {
                running: isActive && index >= root.segmentCount - 2
                loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 150; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 150; easing.type: Easing.InOutQuad }
            }
        }
    }
}
