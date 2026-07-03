import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

PanelWindow {
    id: root

    // Follow the focused monitor: bind `screen` to the focused output. Single
    // window (no per-screen duplicate toasts).
    screen: {
        const _ = NiriState.version
        const scrs = Quickshell.screens
        for (let i = 0; i < scrs.length; i++)
            if (scrs[i].name === NiriState.focusedOutput()) return scrs[i]
        return scrs.length ? scrs[0] : null
    }

    anchors {
        top: true
        right: true
    }

    // The bar's exclusive zone already pushes this below the bar.
    margins.top: 8
    margins.right: Theme.toastMargin

    // Gated only on having notifications, NOT on the focused output — flipping
    // visibility per-screen on focus changes churns the layer-shell window.
    visible: Notifications.tracked.values.length > 0

    implicitWidth: 380
    implicitHeight: Math.max(toastColumn.implicitHeight + 16, 1)
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-notifications"

    Column {
        id: toastColumn
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
            topMargin: 0
            leftMargin: 8
            rightMargin: 8
        }
        spacing: 8

        move: Transition {
            NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.OutCubic }
        }

        Repeater {
            model: Notifications.tracked

            // Toast.qml owns the toast lifecycle: after its timeout it
            // collapses chat-app toasts (kept tracked for the Mod+i picker)
            // and dismisses everything else.
            Toast {
                required property var modelData
                notification: modelData
                width: 360
            }
        }
    }
}
