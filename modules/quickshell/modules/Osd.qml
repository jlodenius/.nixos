import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "."

// Volume/brightness OSD. Volume shows reactively on any sink change (keys,
// bar scroll, apps); brightness is driven by the niri binds calling
// `qs ipc call -- osd brightness <step>`, which runs brightnessctl here.
PanelWindow {
    id: root

    property string mode: "volume"
    property real value: 0
    property bool muted: false

    // Follow the focused monitor, like the notification overlay.
    screen: {
        const _ = NiriState.version
        const scrs = Quickshell.screens
        for (let i = 0; i < scrs.length; i++)
            if (scrs[i].name === NiriState.focusedOutput()) return scrs[i]
        return scrs.length ? scrs[0] : null
    }

    anchors.bottom: true
    margins.bottom: 120
    implicitWidth: 280
    implicitHeight: 48
    color: "transparent"
    visible: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-osd"

    function show(mode, value, muted) {
        root.mode = mode
        root.value = value
        root.muted = muted
        root.visible = true
        hideTimer.restart()
    }
    Timer { id: hideTimer; interval: 1500; onTriggered: root.visible = false }

    readonly property var sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [sink] }

    // Skip the initial property binding at startup — only real changes show.
    property bool settled: false
    Timer { running: true; interval: 1500; onTriggered: root.settled = true }
    Connections {
        target: root.sink ? root.sink.audio : null
        function onVolumeChanged() {
            if (root.settled) root.show("volume", root.sink.audio.volume, root.sink.audio.muted)
        }
        function onMutedChanged() {
            if (root.settled) root.show("volume", root.sink.audio.volume, root.sink.audio.muted)
        }
    }

    IpcHandler {
        target: "osd"
        function brightness(step: string): void {
            bctl.command = ["brightnessctl", "-m", "s", step]
            bctl.running = true
        }
    }
    Process {
        id: bctl
        stdout: StdioCollector {
            onStreamFinished: {
                // e.g. "intel_backlight,backlight,24242,100%,24242"
                const parts = this.text.trim().split(",")
                if (parts.length < 4) return
                const pct = parseInt(parts[3])
                if (!isNaN(pct)) root.show("brightness", pct / 100, false)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: Theme.toastRadius
        border.color: Theme.surface
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: root.mode === "brightness" ? "󰃠"
                    : root.muted ? "\uf026" : "\uf028"
                color: root.muted ? Theme.red : Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 16
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                width: 190
                height: 6
                radius: 3
                color: Theme.selection
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: parent.width * Math.min(1, root.value)
                    height: parent.height
                    radius: 3
                    color: root.muted ? Theme.fg_subtle : Theme.accent
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }
        }
    }
}
