pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Singleton {
    id: root

    property bool locked: false
    readonly property bool passwordActive: pam.active
    property bool splitAuthentication: false

    FileView {
        id: fingerprintService
        path: "/etc/pam.d/quickshell-fingerprint"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.splitAuthentication = true
            root.startFingerprint()
        }
        onLoadFailed: root.splitAuthentication = false
    }

    property string submittedPassword: ""
    property string authError: ""

    signal passwordRejected()

    function unlock() {
        root.locked = false
    }

    function submitPassword(text) {
        if (!locked || pam.active) return
        submittedPassword = text
        if (!pam.start()) {
            submittedPassword = ""
            authError = "Authentication unavailable"
            passwordRejected()
        }
    }

    function startFingerprint() {
        if (locked && splitAuthentication && !fingerprint.active) fingerprint.start()
    }

    onLockedChanged: {
        if (locked) {
            fingerprintService.reload()
            Qt.callLater(startFingerprint)
        } else {
            fingerprintRetry.stop()
            pam.abort()
            fingerprint.abort()
            submittedPassword = ""
            authError = ""
        }
    }
    Component.onCompleted: Qt.callLater(startFingerprint)

    PamContext {
        id: pam
        config: "quickshell"

        onPamMessage: {
            if (responseRequired) respond(root.submittedPassword)
        }
        onCompleted: result => {
            root.submittedPassword = ""
            if (!root.locked) return
            if (result === PamResult.Success) {
                root.unlock()
            } else {
                root.authError = result === PamResult.Failed || result === PamResult.MaxTries
                    ? "Incorrect password" : "Authentication unavailable"
                root.passwordRejected()
            }
        }
        onError: {
            root.submittedPassword = ""
            if (!root.locked) return
            root.authError = "Authentication unavailable"
            root.passwordRejected()
        }
    }

    // Share one reader across all lock surfaces, including multi-monitor setups.
    PamContext {
        id: fingerprint
        config: "quickshell-fingerprint"

        onCompleted: result => {
            if (!root.locked) return
            if (result === PamResult.Success) {
                root.unlock()
            } else if (result !== PamResult.Error) {
                fingerprintRetry.restart()
            }
        }
    }

    Timer {
        id: fingerprintRetry
        interval: 1000
        onTriggered: root.startFingerprint()
    }

    // `unlock` is the escape hatch if PAM ever misbehaves: log into a TTY and
    // run `XDG_RUNTIME_DIR=/run/user/1000 qs ipc call lock unlock`.
    IpcHandler {
        target: "lock"
        function lock()   { root.locked = true }
        function unlock() { root.locked = false }
    }
}
