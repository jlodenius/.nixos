import QtQuick
import Quickshell
import Quickshell.Io
import "."

// Mod+O helium launcher: nix-managed quickmarks + bookmarks, substring
// filtered on label and URL. Typed text with no match opens as a URL if it
// looks like one, else searches DuckDuckGo.
Picker {
    id: root

    open: HeliumPickerState.open
    onCloseRequested: HeliumPickerState.open = false

    placeholder: ""
    subtitleField: "url"
    freeText: query.trim().length > 0 && filtered.length === 0

    onEnter: item => root._openTarget(item.url)
    onEnterText: text => root._openTarget(root._resolve(text))

    property int _gen: 0
    FileView {
        id: quickmarksFile
        path: Quickshell.env("HOME") + "/.config/helium-launcher/quickmarks"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root._gen++
    }
    FileView {
        id: bookmarksFile
        path: Quickshell.env("HOME") + "/.config/helium-launcher/bookmarks"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root._gen++
    }

    items: {
        const _ = root._gen
        return _parse(quickmarksFile.text()).concat(_parse(bookmarksFile.text()))
    }

    // Source lines are "<label> <url>", blank lines and '#' comments allowed.
    function _parse(t) {
        const out = []
        for (const line of (t || "").split("\n")) {
            const s = line.trim()
            if (!s || s.startsWith("#")) continue
            const m = s.match(/^(.*?)\s+(\S+)$/)
            if (m) out.push({ label: m[1].trim(), url: m[2] })
            else out.push({ label: s, url: s })
        }
        return out
    }

    function _resolve(text) {
        const t = text.trim()
        if (t.indexOf("://") !== -1) return t
        if (!/\s/.test(t) && t.indexOf(".") !== -1) return "https://" + t
        return "https://duckduckgo.com/?q=" + encodeURIComponent(t)
    }

    function _openTarget(target) {
        Quickshell.execDetached([
            Quickshell.env("HOME") + "/.config/niri/scripts/helium-open.sh", target])
    }
}
