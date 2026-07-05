import QtQuick
import Quickshell
import ".."

// Unseen chat notification badges, ordered by arrival; apps without unseen
// notifications take no space, and the app you're focused on is suppressed.
// Click opens the notification picker.
Item {
    id: root

    property int _notifTick: 0
    Connections {
        target: Notifications.server
        function onTrackedNotificationsChanged() { root._notifTick++ }
    }

    // One glyph per app with unseen notifications, ordered by each app's
    // oldest unseen notification.
    readonly property var badges: {
        const _ = root._notifTick
        const __ = Notifications.seenGen
        const ___ = Notifications.focusedApp   // re-evaluate on focus changes
        const tracked = Notifications.server ? Notifications.server.trackedNotifications.values : []
        const focusedKey = Notifications.appKey(Notifications.focusedApp)
        const byKey = {}
        const out = []
        for (let i = 0; i < tracked.length; i++) {
            const n = tracked[i]
            if (Notifications.isSeen(n)) continue
            const key = Notifications.appKey(n.appName)
            if (!key || key === focusedKey) continue
            if (!byKey[key]) {
                byKey[key] = { glyph: Notifications.chatApps[key].glyph, firstId: n.id || 0 }
                out.push(byKey[key])
            } else if ((n.id || 0) < byKey[key].firstId) {
                byKey[key].firstId = n.id
            }
        }
        out.sort((a, b) => a.firstId - b.firstId)
        return out
    }

    implicitWidth: visible ? row.implicitWidth + Theme.modulePadH * 2 : 0
    implicitHeight: parent ? parent.height : Theme.barHeight
    visible: badges.length > 0

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: NotificationJumpPickerState.show()
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: root.badges
            delegate: BarText {
                required property var modelData
                text: modelData.glyph
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
