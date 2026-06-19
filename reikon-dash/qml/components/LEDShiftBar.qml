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
    // Tuned for 10k RPM max, 7500 redline
    property var thresholds: [0.50, 0.58, 0.65, 0.70, 0.73, 0.75, 0.78, 0.82]

    // Colors for progressive activation (green → red at redline)
    property var segmentColors: [
        "#00FF00",  // Green - 5000 RPM
        "#7FFF00",  // Yellow-green - 5800 RPM
        "#FFFF00",  // Yellow - 6500 RPM
        "#FFD700",  // Gold - 7000 RPM
        "#FFA500",  // Orange - 7300 RPM
        "#FF0000",  // Red - 7500 RPM (redline)
        "#FF0000",  // Red - 7800 RPM
        "#FF0000"   // Red - 8200 RPM (rev limit)
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
