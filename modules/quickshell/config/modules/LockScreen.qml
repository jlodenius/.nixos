import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "."

// Session lock (ext-session-lock): blurred wallpaper, clock, and a minimal
// underlined password prompt (shakes on failure). Auth goes through PAM
// service "quickshell" (see quickshell.nix).
WlSessionLock {
    id: lock

    locked: LockState.locked

    WlSessionLockSurface {
        id: surface

        color: "black"

        property bool failed: false

        // Bleed past the edges so the blur kernel never samples outside the
        // image (which shows up as a bright halo at the borders).
        Image {
            id: wp
            anchors.fill: parent
            anchors.margins: -64
            source: "file://" + Theme.wallpaper
            fillMode: Image.PreserveAspectCrop
            visible: false
        }
        MultiEffect {
            source: wp
            anchors.fill: wp
            blurEnabled: true
            blur: 1.0
            blurMax: 48
        }
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.35
        }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 88
                font.weight: 300
                renderType: Text.NativeRendering
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "dddd d MMMM")
                color: Theme.fg_muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                renderType: Text.NativeRendering
            }

            Item { width: 1; height: 28 }   // gap before the prompt

            Item {
                id: fieldWrap
                anchors.horizontalCenter: parent.horizontalCenter
                width: 240
                height: 36

                SequentialAnimation {
                    id: shake
                    NumberAnimation { target: fieldWrap; property: "anchors.horizontalCenterOffset"; to: -12; duration: 45 }
                    NumberAnimation { target: fieldWrap; property: "anchors.horizontalCenterOffset"; to: 12; duration: 45 }
                    NumberAnimation { target: fieldWrap; property: "anchors.horizontalCenterOffset"; to: -7; duration: 45 }
                    NumberAnimation { target: fieldWrap; property: "anchors.horizontalCenterOffset"; to: 7; duration: 45 }
                    NumberAnimation { target: fieldWrap; property: "anchors.horizontalCenterOffset"; to: 0; duration: 45 }
                }

                TextInput {
                    id: password
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    enabled: !pam.active
                    focus: true
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    font.letterSpacing: 4
                    cursorDelegate: Rectangle {
                        width: 11
                        color: Theme.fg
                        opacity: 0.7
                    }
                    onTextEdited: surface.failed = false
                    onAccepted: pam.start()
                }

                // Only failure is marked; otherwise nothing but the blurred
                // background and the dots you type.
                Rectangle {
                    visible: surface.failed
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 2
                    radius: 1
                    color: Theme.red
                }
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
                    shake.restart()
                    password.forceActiveFocus()
                }
            }
        }
    }
}
