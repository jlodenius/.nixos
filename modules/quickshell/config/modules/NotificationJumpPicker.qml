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

    placeholder: ""
    glyphField: "glyph"
    glyphColorField: "glyphColor"
    subtitleField: "sub"

    // Only build the list while the picker is (becoming) visible — every
    // message/seen change would otherwise rebuild it on a hidden window.
    items: active ? buildItems(Notifications.tracked, Notifications.seenGen,
                               Notifications.retained, Notifications.retainedGen)
                  : []

    // NOTE: named openItem, NOT activate — Picker has its own activate() that
    // its Enter handling calls; shadowing it breaks Enter inside the picker.
    onEnter: item => root.openItem(item)

    // Mod+i (showOrJump): exactly one unread notification → act on it
    // directly, no picker round-trip; zero or several → the picker as usual.
    Connections {
        target: NotificationJumpPickerState
        function onJumpRequested() {
            const all = Notifications.tracked.values
            const unseen = []
            for (let i = 0; i < all.length; i++)
                if (Notifications.isMessageApp(all[i]) && !Notifications.isSeenId(all[i].id))
                    unseen.push(all[i])
            if (unseen.length === 1) root.openItem(root.mkItemLive(unseen[0]))
            else NotificationJumpPickerState.open = true
        }
    }

    function openItem(item) {
        if (!item || item.divider) return
        NotificationJumpPickerState.open = false
        const n = item.notif   // live Notification, or null for a retained entry
        const key = Notifications.appKey(item.app)
        const app = Notifications.chatApps[key]
        // Claude prompts clear on interact: jump to the source window, done.
        if (app && app.transient) {
            if (n) n.dismiss()
            if (item.windowId)
                Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", item.windowId])
            return
        }
        // The open action deletes the live notification, so retain its display
        // data first (and mark it read) — it stays in the center as history.
        Notifications.retain(item.id, item.app, item.summary, item.windowId)
        Notifications.markSeenById(item.id)
        // Fire the live default action if the app attached one (usually opens
        // the exact channel/thread). Only present while still live.
        if (n && n.actions) {
            const acts = n.actions
            for (let i = 0; i < acts.length; i++) {
                if (acts[i].identifier === "default") { acts[i].invoke(); break }
            }
        }
        // Focus the app's window (or launch it) — unless it's already focused:
        // spawn-or-focus would then cycle to the app's NEXT window, moving
        // focus away from the thread the default action just opened.
        if (app && app.appId && Notifications.appKey(NiriState.focusedAppId()) !== key) {
            Quickshell.execDetached(["sh", "-c",
                Quickshell.env("HOME") + "/.config/niri/scripts/niri-spawn-or-focus.sh "
                + app.appId + " " + app.cmd])
        }
    }

    function mkItemLive(n) {
        const app = Notifications.chatApps[Notifications.appKey(n.appName)]
        return {
            id: n.id, notif: n, app: n.appName || "", summary: n.summary || "",
            windowId: Notifications.windowHint(n),
            label: n.summary || n.appName || "notification",
            glyph: app ? app.glyph : "", glyphColor: Theme.accent,
            sub: app ? app.pretty : (n.appName || ""),
        }
    }

    function mkItemRetained(e) {
        const app = Notifications.chatApps[Notifications.appKey(e.app)]
        return {
            id: e.id, notif: null, app: e.app, summary: e.summary,
            windowId: e.windowId || "",
            label: e.summary || e.app || "notification",
            glyph: app ? app.glyph : "", glyphColor: Theme.accent,
            sub: app ? app.pretty : e.app,
        }
    }

    function buildItems(tracked, sgen, retained, rgen) {
        // Center contents = live tracked chat notifications ∪ retained
        // (messages whose live notification was deleted when opened).
        const live = (tracked && tracked.values) ? tracked.values.slice() : []
        const liveMsgs = live.filter(n => Notifications.isMessageApp(n))
        const liveIds = {}
        const items = []
        for (let i = 0; i < liveMsgs.length; i++) { liveIds[liveMsgs[i].id] = true; items.push(mkItemLive(liveMsgs[i])) }
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
