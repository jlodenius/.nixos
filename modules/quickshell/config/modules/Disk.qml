import QtQuick
import Quickshell
import Quickshell.Io
import "."

// waybar disk: " {percentage_used}%" for /home, every 30s.
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

        Text {
            text: ""
            color: Theme.barFg
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            font.hintingPreference: Font.PreferFullHinting
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.pct
            color: Theme.barFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            font.hintingPreference: Font.PreferFullHinting
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
