import QtQuick
import Quickshell
import Quickshell.Io
import "."

// waybar temperature: "{icon} {temperatureC}°C", critical ≥80 red.
Item {
    id: root

    property int temp: 0
    readonly property bool critical: temp >= 80

    implicitWidth: row.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    Process {
        id: proc
        running: true
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(this.text.trim())
                if (!isNaN(v)) root.temp = Math.round(v / 1000)
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: proc.running = true
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: {
                const icons = ["", "", "", "", ""]
                const idx = Math.min(4, Math.max(0, Math.floor(root.temp / 80 * 5)))
                return icons[idx]
            }
            color: root.critical ? Theme.red : Theme.barFg
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            font.hintingPreference: Font.PreferFullHinting
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: root.temp + "°C"
            color: root.critical ? Theme.red : Theme.barFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            font.hintingPreference: Font.PreferFullHinting
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
