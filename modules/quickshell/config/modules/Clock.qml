import QtQuick
import Quickshell
import "."

// waybar clock#time: "HH:mm".
Item {
    id: root

    implicitWidth: label.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Theme.barFg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
        font.hintingPreference: Font.PreferFullHinting
        renderType: Text.NativeRendering
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
