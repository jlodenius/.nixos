import QtQuick
import Quickshell
import "."

// Unseen chat notification badges: one icon + count per app. Hidden when
// everything is read; the badge for the app you're focused on is suppressed.
// Click opens the notification picker.
Item {
    id: root

    property int _notifTick: 0
    Connections {
        target: Notifications.server
        function onTrackedNotificationsChanged() { root._notifTick++ }
    }

    readonly property var inboxCounts: {
        const _ = root._notifTick
        const __ = Notifications.seenGen
        const ___ = Notifications.focusedApp   // re-evaluate on focus changes
        const model = Notifications.server ? Notifications.server.trackedNotifications : null
        const tracked = model ? model.values : []
        const counts = { slack: 0, discord: 0, teams: 0 }
        for (let i = 0; i < tracked.length; i++) {
            if (Notifications.isSeen(tracked[i])) continue
            const key = Notifications.appKey(tracked[i].appName)
            if (key) counts[key]++
        }
        // Don't badge the client you're focused on — you're already in it.
        const focusedKey = Notifications.appKey(Notifications.focusedApp)
        if (focusedKey) counts[focusedKey] = 0
        return counts
    }
    readonly property int total: inboxCounts.slack + inboxCounts.discord + inboxCounts.teams

    implicitWidth: visible ? row.implicitWidth + Theme.modulePadH * 2 : 0
    implicitHeight: parent ? parent.height : Theme.barHeight
    visible: total > 0

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
            model: [
                { app: "slack",   icon: "󰒱", count: root.inboxCounts.slack },
                { app: "discord", icon: "󰙯", count: root.inboxCounts.discord },
                { app: "teams",   icon: "󰊻", count: root.inboxCounts.teams }
            ]
            delegate: Row {
                required property var modelData
                visible: modelData.count > 0
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: modelData.icon
                    color: Theme.accent
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    font.hintingPreference: Font.PreferFullHinting
                    renderType: Text.NativeRendering
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    visible: modelData.count > 1
                    text: modelData.count
                    color: Theme.barFg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Theme.fontWeight
                    renderType: Text.NativeRendering
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
