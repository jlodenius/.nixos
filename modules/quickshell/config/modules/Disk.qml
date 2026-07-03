import QtQuick
import Quickshell
import Quickshell.Io
import "."

// /home usage percentage.
Item {
    id: root

    property string pct: ""

    implicitWidth: row.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    Process {
        id: proc
        running: true
        command: ["sh", "-c", "df --output=pcent /home | tail -1 | tr -d ' '"]
        stdout: StdioCollector {
            onStreamFinished: root.pct = this.text.trim()
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: proc.running = true
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: "\ued75"
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: root.pct
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
