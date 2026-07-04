import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "."

// Session lock (ext-session-lock): wallpaper + clock + password prompt.
// Auth goes through PAM service "quickshell" (see quickshell.nix).
WlSessionLock {
    id: lock

    locked: LockState.locked

    WlSessionLockSurface {
        id: surface

        property bool failed: false

        Image {
            anchors.fill: parent
            source: "file://" + Theme.wallpaper
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.45
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 64
                font.weight: 600
                renderType: Text.NativeRendering
            }

            TextField {
                id: password
                anchors.horizontalCenter: parent.horizontalCenter
                width: 260
                echoMode: TextInput.Password
                enabled: !pam.active
                focus: true
                color: Theme.fg
                placeholderText: "password"
                placeholderTextColor: Theme.fg_subtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                horizontalAlignment: TextInput.AlignHCenter
                background: Rectangle {
                    color: Theme.bg
                    radius: 8
                    border.width: 1
                    border.color: surface.failed ? Theme.red : Theme.surface
                }
                onTextChanged: surface.failed = false
                onAccepted: pam.start()
            }
        }

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        PamContext {
            id: pam
            config: "quickshell"

            onPamMessage: {
                if (this.responseRequired) this.respond(password.text)
            }
            onCompleted: result => {
                password.text = ""
                if (result === PamResult.Success) {
                    surface.failed = false
                    LockState.locked = false
                } else {
                    surface.failed = true
                    password.forceActiveFocus()
                }
            }
        }
    }
}
