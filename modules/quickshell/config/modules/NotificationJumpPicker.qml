import QtQuick
import Quickshell
import Quickshell.Io
import "."

// Mod+i notification center. Shows only chat-app notifications (Slack,
// Discord, Teams); everything else toasts once and never lands here.
// Entries split by whether you've looked at the source: unseen under
// "current", seen under "earlier". Selecting one fires its live default
// action and focuses (or launches) the app.
Picker {
    id: root

    open: NotificationJumpPickerState.open
    onCloseRequested: NotificationJumpPickerState.open = false

    placeholder: "notification"
    glyphField: "glyph"
    glyphColorField: "glyphColor"
    subtitleField: "sub"

    items: buildItems(Notifications.tracked, Notifications.seenGen,
                      Notifications.retained, Notifications.retainedGen)

    // NOTE: named openItem, NOT activate — Picker has its own activate() that
    // its Enter handling calls; shadowing it breaks Enter inside the picker.
    onEnter: item => root.openItem(item)

    // Mod+i (showOrJump): exactly one toast on screen → act on it directly,
    // no picker round-trip; zero or several → the picker as usual.
    Connections {
        target: NotificationJumpPickerState
        function onJumpRequested() {
            const vis = Notifications.visibleTrayToasts()
            if (vis.length === 1) root.openItem(root.mkItemLive(vis[0]))
            else NotificationJumpPickerState.open = true
        }
    }

    // niri-spawn-or-focus.sh arguments per chat app: [app_id, command].
    readonly property var focusTargets: ({
        "slack":   ["Slack", "slack"],
        "discord": ["discord", "discord"],
        "teams":   ["teams-for-linux", "teams-for-linux"]
    })

    function openItem(item) {
        if (!item || item.divider) return
        NotificationJumpPickerState.open = false
        const n = item.notif   // live Notification, or null for a retained entry
        // The open action deletes the live notification, so retain its display
        // data first (and mark it read) — it stays in the center as history.
        Notifications.retain(item.id, item.app, item.summary)
        Notifications.markSeenById(item.id)
        // Fire the live default action if the app attached one (usually opens
        // the exact channel/thread). Only present while still live.
        if (n && n.actions) {
            const acts = n.actions
            for (let i = 0; i < acts.length; i++) {
                if (acts[i].identifier === "default") { acts[i].invoke(); break }
            }
        }
        // Focus the app's window (or launch it).
        const target = focusTargets[Notifications.appKey(item.app)]
        if (target) {
            Quickshell.execDetached(["sh", "-c",
                Quickshell.env("HOME") + "/.config/niri/scripts/niri-spawn-or-focus.sh "
                + target[0] + " " + target[1]])
        }
    }

    function _glyph(appName) {
        const key = Notifications.appKey(appName)
        if (key === "slack") return "󰒱"
        if (key === "discord") return "󰙯"
        if (key === "teams") return "󰊻"
        return ""
    }

    function _pretty(appName) {
        const key = Notifications.appKey(appName)
        if (key === "slack") return "Slack"
        if (key === "discord") return "Discord"
        if (key === "teams") return "Teams"
        return appName || ""
    }

    function mkItemLive(n) {
        return {
            id: n.id, notif: n, app: n.appName || "", summary: n.summary || "",
            label: n.summary || n.appName || "notification",
            glyph: _glyph(n.appName), glyphColor: Theme.accent,
            sub: _pretty(n.appName),
        }
    }

    function mkItemRetained(e) {
        return {
            id: e.id, notif: null, app: e.app, summary: e.summary,
            label: e.summary || e.app || "notification",
            glyph: _glyph(e.app), glyphColor: Theme.accent,
            sub: _pretty(e.app),
        }
    }

    function buildItems(tracked, sgen, retained, rgen) {
        // Center contents = live tracked chat notifications ∪ retained
        // (messages whose live notification was deleted when opened).
        const live = (tracked && tracked.values) ? tracked.values.slice() : []
        const liveTray = live.filter(n => Notifications.isTrayApp(n))
        const liveIds = {}
        const items = []
        for (let i = 0; i < liveTray.length; i++) { liveIds[liveTray[i].id] = true; items.push(mkItemLive(liveTray[i])) }
        const ret = retained || []
        for (let i = 0; i < ret.length; i++) if (!liveIds[ret[i].id]) items.push(mkItemRetained(ret[i]))
        items.sort((a, b) => (b.id || 0) - (a.id || 0))   // newest first
        const unseen = items.filter(it => !Notifications.isSeenId(it.id))
        const seen = items.filter(it => Notifications.isSeenId(it.id))
        const out = []
        if (unseen.length) {
            out.push({ divider: true, label: "current" })
            for (let i = 0; i < unseen.length; i++) out.push(unseen[i])
        }
        if (seen.length) {
            out.push({ divider: true, label: "earlier" })
            for (let i = 0; i < seen.length; i++) out.push(seen[i])
        }
        return out
    }
}
