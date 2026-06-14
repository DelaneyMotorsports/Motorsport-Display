/**
 * @file    LabeledGauge.qml
 * @brief   Arc gauge with integrated label and digital readout.
 *
 * Combines GaugeArc with text labels for gauge name, current value, and units.
 * Provides complete telemetry visualization in a compact, reusable component.
 *
 * Properties:
 * - value/minValue/maxValue: Gauge range (inherited from GaugeArc)
 * - arcColor: Gauge arc color
 * - labelText: Gauge name (e.g., "COOLANT")
 * - units: Measurement units (e.g., "°C", "bar", "km/h")
 * - decimalPlaces: Number formatting precision
 *
 * Design Philosophy:
 * - Self-contained gauge with all necessary information
 * - Clean, professional motorsport aesthetic
 * - Configurable for multiple telemetry types
 *
 * Dependencies: Qt 6.x Quick
 *
 * @author  Kevin Delaney
 * @date    January 14, 2026
 * @company Delaney Motorsports, LLC
 * @address Sarasota, FL
 */

import QtQuick
import "../components"

Item {
    id: root

    property real value: 0
    property real minValue: 0
    property real maxValue: 100
    property color arcColor: "#00ff00"
    property string labelText: "GAUGE"
    property string units: ""
    property int decimalPlaces: 0

    // Top label
    Text {
        id: label
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        text: root.labelText
        font.pixelSize: 16
        font.bold: true
        color: "#aaaaaa"
    }

    // Arc gauge
    GaugeArc {
        id: gauge
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        width: parent.width
        height: parent.height - 40
        value: root.value
        minValue: root.minValue
        maxValue: root.maxValue
        arcColor: root.arcColor
    }

    // Center value display
    Column {
        anchors.centerIn: gauge
        spacing: 5

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.value.toFixed(root.decimalPlaces)
            font.pixelSize: 48
            font.bold: true
            color: "#ffffff"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.units
            font.pixelSize: 18
            color: "#aaaaaa"
        }
    }
}
