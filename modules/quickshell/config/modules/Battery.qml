import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "."

// Battery percentage; warning ≤30 yellow, critical ≤15 red.
Item {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery ? battery.percentage * 100 : 0
    // Don't name this `state` — Item.state is a built-in string property and
    // shadowing it makes the enum comparison below silently fail.
    readonly property int chargeState: battery ? battery.state : 0
    readonly property bool charging: chargeState === UPowerDeviceState.Charging
                                  || chargeState === UPowerDeviceState.FullyCharged

    implicitWidth: visible ? row.implicitWidth + Theme.modulePadH * 2 : 0
    implicitHeight: parent ? parent.height : Theme.barHeight
    visible: battery && battery.isPresent

    readonly property color stateColor: {
        if (charging) return Theme.barFg
        if (percentage <= 15) return Theme.red
        if (percentage <= 30) return Theme.yellow
        return Theme.barFg
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: {
                if (root.charging) return ""
                const buckets = ["", "", "", "", ""]
                const idx = Math.min(4, Math.max(0, Math.floor(root.percentage / 20)))
                return buckets[idx]
            }
            color: root.stateColor
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: Math.round(root.percentage) + "%"
            color: root.stateColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
