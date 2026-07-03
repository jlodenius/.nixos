import QtQuick
import Quickshell
import "."

// niri workspaces on this output; active one white, rest subtle (waybar style).
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

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: ws.name || ws.idx
                    color: parent.isActive ? Theme.barFg
                         : ws.is_urgent ? Theme.red
                         : Theme.fg_subtle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    font.hintingPreference: Font.PreferFullHinting
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(
                        ["niri", "msg", "action", "focus-workspace", String(parent.ws.idx)])
                }
            }
        }
    }
}
