import QtQuick
import Quickshell
import "."

// niri workspaces on this output; active one white, rest subtle.
Item {
    id: root

    property string output: ""

    readonly property var groups: {
        const _ = NiriState.version
        return NiriState.visibleWorkspaces(root.output)
    }

    implicitWidth: row.implicitWidth + Theme.modulePadH
    implicitHeight: parent ? parent.height : Theme.barHeight

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.modulePadH / 2
        spacing: 0

        Repeater {
            model: root.groups

            Item {
                required property var modelData
                readonly property var ws: modelData.ws
                readonly property bool isActive: ws.is_active === true
                width: label.implicitWidth + 10
                height: root.height

                BarText {
                    id: label
                    anchors.centerIn: parent
                    text: ws.name || ws.idx
                    color: parent.isActive ? Theme.barFg
                         : ws.is_urgent ? Theme.red
                         : Theme.fg_subtle
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    // focus-workspace resolves the index against the focused
                    // monitor, so focus this bar's monitor first.
                    onClicked: Quickshell.execDetached(["sh", "-c",
                        (root.output ? "niri msg action focus-monitor '" + root.output + "' && " : "")
                        + "niri msg action focus-workspace " + parent.ws.idx])
                }
            }
        }
    }
}
