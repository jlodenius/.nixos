import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "."

// waybar pulseaudio: "{icon} {volume}%", muted red, click → pavucontrol,
// scroll adjusts volume by 1%.
Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property bool headphones: {
        if (!sink) return false
        const n = (sink.name || "").toLowerCase()
        const d = (sink.description || "").toLowerCase()
        return n.indexOf("bluez") >= 0 || d.indexOf("headphone") >= 0
            || d.indexOf("headset") >= 0
    }

    implicitWidth: visible ? row.implicitWidth + Theme.modulePadH * 2 : 0
    implicitHeight: parent ? parent.height : Theme.barHeight
    visible: sink !== null

    // Required for quickshell to subscribe to sink property changes.
    PwObjectTracker {
        objects: [sink]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["pavucontrol"])
        onWheel: wheel => {
            if (!root.sink || !root.sink.audio) return
            const step = wheel.angleDelta.y > 0 ? 0.01 : -0.01
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step))
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: {
                if (muted) return ""
                if (headphones) return ""
                return volume > 0.5 ? "" : ""
            }
            color: muted ? Theme.red : Theme.barFg
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            font.hintingPreference: Font.PreferFullHinting
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: Math.round(volume * 100) + "%"
            color: muted ? Theme.red : Theme.barFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            font.hintingPreference: Font.PreferFullHinting
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
