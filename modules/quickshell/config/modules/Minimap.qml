import QtQuick
import "."

// One thin bar per window, grouped by workspace (gaps between); the focused
// window is taller and accent-colored, other workspaces' active windows white.
Item {
    id: root

    property string output: ""
    readonly property int maxSlots: 64

    implicitWidth: Math.max(row.implicitWidth + Theme.modulePadH * 2, 60)
    implicitHeight: parent ? parent.height : Theme.barHeight

    readonly property var entries: {
        const _ = NiriState.version
        return NiriState.minimapEntries(root.output)
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

                readonly property string kind: entry ? entry.kind : "gap"
                readonly property bool isBar: kind === "bar"
                readonly property bool isFocused: isBar && entry.focused === true
                readonly property bool isWsActive: isBar && entry.wsActive === true

                width: kind === "gap" ? 12 : 3
                height: root.height - 6
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    visible: cell.isBar
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: cell.isFocused ? Theme.accent
                         : cell.isWsActive ? Theme.barFg
                         : Theme.dimmedFg
                    width: cell.isFocused ? 3 : 2
                    height: {
                        if (cell.isFocused) return 18
                        if (cell.isWsActive) return 14
                        return 11
                    }
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

                Rectangle {
                    visible: cell.kind === "dot"
                    anchors.centerIn: parent
                    width: 3
                    height: 3
                    radius: 1.5
                    color: Theme.barFg
                }
            }
        }
    }
}
