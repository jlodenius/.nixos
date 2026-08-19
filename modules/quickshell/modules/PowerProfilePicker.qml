import QtQuick
import Quickshell
import Quickshell.Io
import "."

Picker {
    id: root

    property string currentProfile: ""

    open: PowerProfilePickerState.open
    onCloseRequested: PowerProfilePickerState.open = false

    placeholder: "Power profile"
    glyphField: "glyph"
    glyphColorField: "glyphColor"
    subtitleField: "description"

    items: [
        {
            label: "Power Saver",
            profile: "power-saver",
            description: "Maximum battery life",
            glyph: currentProfile === "power-saver" ? "" : "",
            glyphColor: Theme.accent
        },
        {
            label: "Balanced",
            profile: "balanced",
            description: "Adapts to AC or battery",
            glyph: currentProfile === "balanced" ? "" : "",
            glyphColor: Theme.accent
        },
        {
            label: "Performance",
            profile: "performance",
            description: "Maximum performance",
            glyph: currentProfile === "performance" ? "" : "",
            glyphColor: Theme.accent
        }
    ]

    onEnter: item => root.setProfile(item.profile)

    Connections {
        target: PowerProfilePickerState
        function onOpenChanged() {
            if (PowerProfilePickerState.open) root.refresh()
        }
    }

    Process {
        id: getProfile
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const profile = this.text.trim()
                if (!profile) return
                root.currentProfile = profile
                for (let i = 0; i < root.items.length; i++) {
                    if (root.items[i].profile === profile) {
                        root.selectedIndex = i
                        break
                    }
                }
            }
        }
    }

    Process {
        id: setProfileProc
        onExited: getProfile.running = true
    }

    function refresh() {
        getProfile.running = true
    }

    function setProfile(profile) {
        currentProfile = profile
        setProfileProc.command = ["powerprofilesctl", "set", profile]
        setProfileProc.running = true
    }
}
