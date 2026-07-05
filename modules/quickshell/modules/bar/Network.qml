import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// Wifi SSID / wired / disconnected (red).
Item {
    id: root

    property string kind: "disconnected"
    property string label: "Disconnected"

    implicitWidth: row.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    Process {
        id: proc
        running: true
        command: ["sh", "-c",
            "ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '/^yes:/ {sub(/^yes:/, \"\"); print; exit}'); " +
            "if [ -n \"$ssid\" ]; then echo \"wifi $ssid\"; else " +
            "  eth=$(nmcli -t -f TYPE,DEVICE connection show --active 2>/dev/null | awk -F: '/^802-3-ethernet:/ {print $2; exit}'); " +
            "  if [ -n \"$eth\" ]; then echo \"eth\"; else echo \"none\"; fi; " +
            "fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim()
                if (t.startsWith("wifi ")) {
                    root.kind = "wifi"
                    root.label = t.substring(5)
                } else if (t === "eth") {
                    root.kind = "eth"
                    root.label = "eth"
                } else {
                    root.kind = "disconnected"
                    root.label = "Disconnected"
                }
            }
        }
    }

    // Requery on NetworkManager events instead of polling every few seconds.
    Process {
        id: monitor
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: () => { proc.running = true }
        }
        onExited: monitorRestart.start()
    }
    Timer {
        id: monitorRestart
        interval: 5000
        onTriggered: monitor.running = true
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: root.kind === "wifi" ? ""
                : root.kind === "eth" ? "󰈀"
                : "⚠"
            color: root.kind === "disconnected" ? Theme.red : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: root.label
            color: root.kind === "disconnected" ? Theme.red : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
