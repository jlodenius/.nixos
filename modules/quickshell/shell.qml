import Quickshell
import QtQml
import "modules"
import "modules/bar"

ShellRoot {
    id: root

    // One wallpaper + bar per monitor; Variants reconciles when monitors
    // come and go.
    Variants {
        model: Quickshell.screens
        Wallpaper {
            required property var modelData
            screen: modelData
        }
    }
    Variants {
        model: Quickshell.screens
        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // Single toast overlay following the focused monitor.
    NotificationOverlay {}

    NotificationJumpPicker {}
    HeliumPicker {}
    Osd {}
    LockScreen {}
    BatteryAlert {}
}
