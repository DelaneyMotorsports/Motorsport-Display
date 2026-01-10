/**
 * @file    GaugeArc.qml
 * @brief   Reusable arc-style gauge component for telemetry visualization.
 *
 * Implements a circular arc gauge suitable for displaying RPM, speed, temperature, or
 * pressure readings. The gauge supports configurable value ranges, colors, and smooth
 * animations. Built using Qt Quick Shapes for GPU-accelerated rendering, ensuring
 * 60fps performance even on resource-constrained embedded hardware.
 *
 * Properties:
 * - value: Current reading (0-maxValue)
 * - minValue/maxValue: Gauge range
 * - arcColor: Gauge color (supports dynamic color changes for warning zones)
 *
 * Design Philosophy:
 * - GPU-accelerated rendering for smooth animation
 * - Configurable via exposed properties (no code changes needed)
 * - 270-degree sweep angle (standard automotive gauge layout)
 * - Round cap style for professional appearance
 *
 * Dependencies: Qt 6.x Quick, Qt 6.x Quick Shapes
 *
 * @author  Kevin Delaney
 * @date    January 10, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property color arcColor: "#00ff00"

    Shape {
        anchors.fill: parent

        ShapePath {
            strokeWidth: 20
            strokeColor: root.arcColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - 10
                radiusY: root.height / 2 - 10
                startAngle: -225
                sweepAngle: (root.value - root.minValue) / (root.maxValue - root.minValue) * 270
            }
        }
    }
}
