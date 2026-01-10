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
