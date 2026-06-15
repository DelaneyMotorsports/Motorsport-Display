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
            radius: 2

            // Calculate if this segment should be lit
            property real threshold: root.thresholds[index]
            property bool isActive: (root.rpm / root.maxRpm) >= threshold

            color: isActive ? root.segmentColors[index] : "#222222"
            border.color: isActive ? Qt.lighter(root.segmentColors[index], 1.2) : "#111111"
            border.width: 1

            // Smooth transitions
            Behavior on color {
                ColorAnimation { duration: 100 }
            }

            // Pulse effect when active
            SequentialAnimation on opacity {
                running: isActive && index >= root.segmentCount - 2
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 200 }
                NumberAnimation { to: 1.0; duration: 200 }
            }
        }
    }
}
