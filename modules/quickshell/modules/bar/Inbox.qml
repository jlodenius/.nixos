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
        const ____ = Notifications.retainedGen
        const tracked = Notifications.server ? Notifications.server.trackedNotifications.values : []
        const focusedKey = Notifications.appKey(Notifications.focusedApp)
        const byKey = {}
        const out = []
        const counted = {}
        function add(id, app) {
            const key = Notifications.appKey(app)
            if (!key || key === focusedKey) return
            if (!byKey[key]) {
                byKey[key] = { glyph: Notifications.chatApps[key].glyph, firstId: id || 0 }
                out.push(byKey[key])
            } else if ((id || 0) < byKey[key].firstId) {
                byKey[key].firstId = id
            }
        }
        for (let i = 0; i < tracked.length; i++) {
            const n = tracked[i]
            counted[n.id] = true
            if (Notifications.isSeen(n)) continue
            add(n.id, n.appName)
        }
        // Retained snapshots whose live notification the app retracted (Teams)
        // still badge until seen.
        const ret = Notifications.retained
        for (let i = 0; i < ret.length; i++) {
            const e = ret[i]
            if (counted[e.id] || Notifications.isSeenId(e.id)) continue
            add(e.id, e.app)
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
