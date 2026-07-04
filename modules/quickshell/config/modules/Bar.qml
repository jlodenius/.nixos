import QtQuick
import Quickshell
import "."

// Workspaces + minimap + chat inbox left, system widgets right.
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    margins.top: Theme.barMargin
    margins.left: Theme.barMargin
    margins.right: Theme.barMargin
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.barBg
        radius: Theme.barRadius

        Row {
            id: leftGroup
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: 4
            }
            spacing: 0

            Workspaces { output: bar.screen ? bar.screen.name : "" }
            Minimap { output: bar.screen ? bar.screen.name : "" }
            Inbox {}
        }

        Row {
            id: rightGroup
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                rightMargin: 4
            }
            spacing: 0

            Dnd {}
            Stockfin {}
            Network {}
            Audio {}
            Disk {}
            Cpu {}
            Temperature {}
            Battery {}
            Clock {}
        }
    }
}
