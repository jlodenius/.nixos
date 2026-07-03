import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "."

// Default sink volume; muted red, click → pavucontrol, scroll ±1%.
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
            if (wheel.angleDelta.y === 0) return   // ignore horizontal scroll
            const step = wheel.angleDelta.y > 0 ? 0.01 : -0.01
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step))
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        BarText {
            text: {
                if (muted) return ""
                if (headphones) return ""
                return volume > 0.5 ? "" : ""
            }
            color: muted ? Theme.red : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
        BarText {
            text: Math.round(volume * 100) + "%"
            color: muted ? Theme.red : Theme.barFg
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
