pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "."

Singleton {
    id: root

    readonly property alias server: notifServer
    readonly property alias tracked: notifServer.trackedNotifications

    // Notifications are a persistent center: chat messages never auto-dismiss,
    // so Mod+i always shows recent ones. Focusing a notification's source app
    // marks it "seen" — it stays tracked but moves to the picker's "earlier"
    // group instead of vanishing. seenGen bumps on every change so bindings
    // that read seenIds re-evaluate.
    property var seenIds: ({})
    property int seenGen: 0
    function markSeen(n) {
        if (n) root.markSeenById(n.id)
    }
    function markSeenById(id) {
        if (id !== undefined && !root.seenIds[id]) { root.seenIds[id] = true; root.seenGen++ }
    }
    function isSeen(n) {
        return !!(n && root.isSeenId(n.id))
    }
    function isSeenId(id) {
        const _ = root.seenGen
        // Not live = restored across a reload (keepOnReload); treat as seen so a
        // rebuild doesn't resurface already-read messages (seenIds resets on reload).
        if (id !== undefined && !root.liveIds[id]) return true
        return !!root.seenIds[id]
    }

    // Only ids delivered via onNotification are "live"; notifications restored
    // across a reload (keepOnReload) never enter liveIds, so isSeenId treats
    // them as seen and their toast stays collapsed while they still show in
    // the Mod+i history.
    property var liveIds: ({})

    // Backstop: suppress every toast entrance for a short settle window after
    // launch, in case a restore re-fires onNotification.
    property bool startupSettled: false
    Timer {
        running: true
        interval: 1500
        onTriggered: root.startupSettled = true
    }

    // Opening a message fires its default action, and quickshell deletes a
    // notification the instant its action is invoked. To keep the Mod+i center
    // a real history, retain its display data at that moment; the picker shows
    // tracked (live) ∪ retained.
    property var retained: []      // newest-first: {id, app, summary}
    property int retainedGen: 0
    function retain(id, app, summary) {
        if (id === undefined) return
        root.retained = root.retained.filter(e => e.id !== id)
        root.retained.unshift({ id: id, app: app || "", summary: summary || "" })
        if (root.retained.length > root.messageMax)
            root.retained = root.retained.slice(0, root.messageMax)
        root.retainedGen++
    }

    // Chat-app registry: the single source for name matching (notification
    // appNames and niri app_ids, matched exactly, lowercased), badge glyphs,
    // display names, and the niri-spawn-or-focus target. Consumed by Inbox
    // and NotificationJumpPicker.
    readonly property var chatApps: ({
        slack:   { names: ["slack"],
                   glyph: "󰒱", pretty: "Slack", appId: "Slack", cmd: "slack" },
        discord: { names: ["discord", "vesktop"],
                   glyph: "󰙯", pretty: "Discord", appId: "discord", cmd: "discord" },
        teams:   { names: ["teams-for-linux", "microsoft teams", "teams"],
                   glyph: "󰊻", pretty: "Teams", appId: "teams-for-linux", cmd: "teams-for-linux" }
    })
    function appKey(name) {
        const a = (name || "").toLowerCase()
        for (const key in root.chatApps)
            if (root.chatApps[key].names.indexOf(a) !== -1) return key
        return ""
    }
    // Only chat-app notifications persist in the Mod+i center. Everything else
    // (screenshots, system notify-send, etc.) still toasts once — see Toast.qml
    // — then drops.
    function isMessageApp(n) {
        return !!(n && root.appKey(n.appName))
    }

    // Conversation key: the desktop apps put the channel/sender in the summary,
    // so app + summary identifies a conversation well enough for collapsing.
    function _convKey(app, summary) {
        return root.appKey(app) + "|" + (summary || "")
    }

    // One entry per conversation: a new message supersedes earlier ones with
    // the same key, dropping both the live tracked copies and any retained
    // (already-opened) entry, so the center shows the latest line only.
    function _collapseConversation(n) {
        if (!n) return
        const key = root._convKey(n.appName, n.summary)
        const all = notifServer.trackedNotifications.values.slice()
        for (let i = 0; i < all.length; i++) {
            const o = all[i]
            if (!o || o.id === n.id) continue
            if (root.isMessageApp(o) && root._convKey(o.appName, o.summary) === key) {
                delete root.seenIds[o.id]
                o.dismiss()
            }
        }
        const before = root.retained.length
        root.retained = root.retained.filter(e => root._convKey(e.app, e.summary) !== key)
        if (root.retained.length !== before) root.retainedGen++
    }

    // Keep the most recent messageMax chat messages as history (seen or not).
    readonly property int messageMax: 30
    function enforceCap() {
        const msgs = notifServer.trackedNotifications.values.filter(n => root.isMessageApp(n))
        if (msgs.length <= root.messageMax) return
        msgs.sort((a, b) => (a.id || 0) - (b.id || 0))   // oldest first
        for (let i = 0; i < msgs.length - root.messageMax; i++) {
            delete root.seenIds[msgs[i].id]
            msgs[i].dismiss()
        }
    }

    readonly property string focusedApp: {
        const _ = NiriState.version
        return NiriState.focusedAppId()
    }
    readonly property string focusedKey: {
        const _ = NiriState.version
        return focusedApp + " " + NiriState.focusedWorkspaceName()
    }

    // Focusing a chat app's window marks its notifications read (they survive
    // as history in the "earlier" group; only the badge clears).
    onFocusedKeyChanged: {
        const key = root.appKey(focusedApp)
        if (!key) return
        const all = notifServer.trackedNotifications.values.slice()
        for (let i = 0; i < all.length; i++) {
            if (root.appKey(all[i].appName) === key) root.markSeen(all[i])
        }
    }

    NotificationServer {
        id: notifServer
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true

        onNotification: notification => {
            delete root.seenIds[notification.id]
            root.liveIds[notification.id] = true
            notification.tracked = true
            // Arrivals during the post-reload settle window are restores
            // re-fired by keepOnReload, not genuinely new — mark them seen so
            // they land in "earlier"/off the badge.
            if (!root.startupSettled) root.markSeenById(notification.id)
            if (root.isMessageApp(notification))
                root._collapseConversation(notification)
            root.enforceCap()
        }
    }

    function _findById(id) {
        const num = parseInt(id)
        const all = notifServer.trackedNotifications.values
        for (let i = 0; i < all.length; i++) if (all[i].id === num) return all[i]
        return null
    }

    IpcHandler {
        target: "notifications"

        function list(): string {
            const all = notifServer.trackedNotifications.values
            const out = []
            for (let i = 0; i < all.length; i++) {
                const n = all[i]
                out.push({
                    id: n.id,
                    app_name: n.appName,
                    summary: n.summary,
                    body: n.body,
                    actions: (n.actions || []).map(a => ({ id: a.identifier, name: a.text }))
                })
            }
            return JSON.stringify(out)
        }

        function invoke(id: string): string {
            const n = root._findById(id)
            if (!n) return "no-such-notification"
            const actions = n.actions || []
            for (let i = 0; i < actions.length; i++) {
                if (actions[i].identifier === "default" || actions[i].name === "default") {
                    actions[i].invoke()
                    return "invoked"
                }
            }
            if (actions.length > 0) {
                actions[0].invoke()
                return "invoked-first"
            }
            return "no-actions"
        }

        function dismiss(id: string): string {
            const n = root._findById(id)
            if (!n) return "no-such-notification"
            n.dismiss()
            return "dismissed"
        }

        function dismissAll(): string {
            const all = notifServer.trackedNotifications.values.slice()
            for (let i = 0; i < all.length; i++) all[i].dismiss()
            return "dismissed " + all.length
        }
    }
}
