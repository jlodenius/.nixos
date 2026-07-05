import QtQuick
import Quickshell
import ".."

Item {
    id: root

    implicitWidth: label.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    BarText {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "HH:mm")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
