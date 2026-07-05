import QtQuick
import Quickshell
import Quickshell.Io
import ".."

// CPU temperature; critical ≥80 red.
Item {
    id: root

    property int temp: 0
    readonly property bool critical: temp >= 80

    implicitWidth: row.implicitWidth + Theme.modulePadH * 2
    implicitHeight: parent ? parent.height : Theme.barHeight

    FileView {
        id: zone
        path: "/sys/class/thermal/thermal_zone0/temp"
        onLoaded: {
            const v = parseInt((text() || "").trim())
            if (!isNaN(v)) root.temp = Math.round(v / 1000)
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: zone.reload()
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: {
                const icons = ["", "", "", "", ""]
                const idx = Math.min(4, Math.max(0, Math.floor(root.temp / 80 * 5)))
                return icons[idx]
            }
            color: root.critical ? Theme.red : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: root.temp + "°C"
            color: root.critical ? Theme.red : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
