import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Polls the stockfin D-Bus StatusJson property, colors by bullish/bearish
// class, click activates.
Item {
    id: root

    property string label: ""
    property string cls: ""

    implicitWidth: visible ? row.implicitWidth + Theme.modulePadH * 2 : 0
    implicitHeight: parent ? parent.height : Theme.barHeight
    visible: label.length > 0

    Process {
        id: proc
        running: true
        command: ["busctl", "--user", "get-property",
            "org.jlodenius.stockfin.Waybar", "/org/jlodenius/stockfin",
            "org.jlodenius.stockfin", "StatusJson"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Output form: s "{\"text\": ..., \"class\": ...}"
                const raw = this.text.trim()
                if (!raw.startsWith("s \"")) { root.label = ""; return }
                const json = raw.slice(3, -1).replace(/\\(.)/g, "$1")
                try {
                    const data = JSON.parse(json)
                    root.label = data.text || ""
                    root.cls = Array.isArray(data.class) ? (data.class[0] || "") : (data.class || "")
                } catch (e) {
                    root.label = ""
                }
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: proc.running = true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["busctl", "--user", "call",
            "org.jlodenius.stockfin.Waybar", "/org/jlodenius/stockfin",
            "org.jlodenius.stockfin", "Activate"])
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: ""
            color: root.cls === "bullish" ? Theme.green
                 : root.cls === "bearish" ? Theme.red
                 : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: root.label
            color: root.cls === "bullish" ? Theme.green
                 : root.cls === "bearish" ? Theme.red
                 : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
