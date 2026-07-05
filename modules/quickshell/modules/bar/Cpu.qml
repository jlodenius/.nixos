import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// CPU usage; warning ≥70 yellow, critical ≥90 red.
Item {
    id: root

    property int usage: 0
    property int prevTotal: 0
    property int prevIdle: 0

    implicitWidth: row.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = (text() || "").split("\n")[0].trim().split(/\s+/)
            if (f[0] !== "cpu" || f.length < 8) return
            const idle = parseInt(f[4]) + parseInt(f[5])
            let total = 0
            for (let i = 1; i <= 7; i++) total += parseInt(f[i]) || 0
            if (root.prevTotal > 0) {
                const dt = total - root.prevTotal
                const di = idle - root.prevIdle
                if (dt > 0) root.usage = Math.round(100 * (dt - di) / dt)
            }
            root.prevIdle = idle
            root.prevTotal = total
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: stat.reload()
    }

    readonly property color stateColor: usage >= 90 ? Theme.red
                                      : usage >= 70 ? Theme.yellow
                                      : Theme.barFg

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: ""
            color: root.stateColor
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: root.usage + "%"
            color: root.stateColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
