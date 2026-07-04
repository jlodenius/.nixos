pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    function toggle() { active = !active }

    IpcHandler {
        target: "dnd"
        function toggle() { root.toggle() }
    }
}
