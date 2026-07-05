import QtQuick
import ".."

// Bell-off indicator while do-not-disturb is active; click toggles it off.
Item {
    id: root

    implicitWidth: visible ? icon.implicitWidth + Theme.modulePadH * 2 : 0
    implicitHeight: parent ? parent.height : Theme.barHeight
    visible: DndState.active

    BarText {
        id: icon
        anchors.centerIn: parent
        text: "󰂛"
        color: Theme.accent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: DndState.toggle()
    }
}
