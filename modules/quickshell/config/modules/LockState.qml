pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool locked: false

    // `unlock` is the escape hatch if PAM ever misbehaves: log into a TTY and
    // run `XDG_RUNTIME_DIR=/run/user/1000 qs ipc call lock unlock`.
    IpcHandler {
        target: "lock"
        function lock()   { root.locked = true }
        function unlock() { root.locked = false }
    }
}
