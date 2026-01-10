import QtQuick

Rectangle {
    id: root

    width: 200
    height: 50
    color: active ? "#ff0000" : "#333333"
    radius: 5

    property bool active: false

    SequentialAnimation on opacity {
        running: root.active
        loops: Animation.Infinite

        NumberAnimation { to: 0.3; duration: 200 }
        NumberAnimation { to: 1.0; duration: 200 }
    }
}
