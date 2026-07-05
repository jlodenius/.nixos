import QtQuick
import ".."

// Horizontal overview of the active workspace only: one thin bar per window
// column, the focused window taller and accent-colored. The vertical
// (workspace) axis is covered by the Workspaces numbers next to it.
Item {
    id: root

    property string output: ""
    readonly property int maxSlots: 32

    implicitWidth: row.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    readonly property var entries: {
        const _ = NiriState.version
        return NiriState.activeWorkspaceWindows(root.output)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.maxSlots

            Item {
                id: cell
                required property int index
                readonly property var entry: index < root.entries.length ? root.entries[index] : null
                visible: entry !== null

                readonly property bool isFocused: entry ? entry.focused === true : false

                width: 3
                height: root.height - 6
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: cell.isFocused ? Theme.accent : Theme.dimmedFg
                    width: cell.isFocused ? 3 : 2
                    height: cell.isFocused ? 18 : 11
                    radius: 1
                    Behavior on width {
                        NumberAnimation {
                            duration: 110
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.34, 1.56, 0.64, 1.0, 1.0, 1.0]
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: 110
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.34, 1.56, 0.64, 1.0, 1.0, 1.0]
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 110 } }
                }
            }
        }
    }
}
