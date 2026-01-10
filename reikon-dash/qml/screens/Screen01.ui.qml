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
