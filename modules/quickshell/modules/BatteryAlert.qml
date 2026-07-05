import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Fires a critical notification at 15% and 5% while discharging, once per
// threshold per discharge cycle. Instantiated once in shell.qml (the bar's
// Battery widget exists per screen, which would duplicate warnings).
Item {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery ? battery.percentage * 100 : 100
    readonly property bool charging: battery
        && (battery.state === UPowerDeviceState.Charging
            || battery.state === UPowerDeviceState.FullyCharged)

    property int warnedAt: 100

    onChargingChanged: if (charging) warnedAt = 100
    onPercentageChanged: {
        if (charging || !battery || !battery.isPresent) return
        const p = Math.round(percentage)
        for (const t of [15, 5]) {
            if (p <= t && warnedAt > t) {
                warnedAt = t
                Quickshell.execDetached(["notify-send", "-u", "critical",
                    "-a", "battery", "Battery low", p + "% remaining"])
                break
            }
        }
    }
}
