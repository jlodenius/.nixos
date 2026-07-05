pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme

    // Palette single-source: modules/colours.nix, exported to JSON by
    // quickshell.nix. watchChanges reflows the shell when a rebuild changes
    // the palette; a broken file logs a parse error and keeps the last state.
    FileView {
        path: Quickshell.env("HOME") + "/.local/share/quickshell/colours.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: c
            property color background
            property color surface
            property color selection
            property color subtle
            property color comment
            property color foreground
            property color red
            property color yellow
            property color green
            property color cyan
            property color blue
            property color magenta
            property var muted
            property var dark
        }
    }

    readonly property color bg: c.background
    readonly property color surface: c.surface
    readonly property color selection: c.selection
    readonly property color fg: c.foreground
    readonly property color fg_muted: c.comment
    readonly property color fg_subtle: c.subtle

    readonly property color red: c.red
    readonly property color yellow: c.yellow
    readonly property color green: c.green
    readonly property color cyan: c.cyan
    readonly property color blue: c.blue
    readonly property color magenta: c.magenta

    readonly property color accent: yellow
    readonly property color hairline: Qt.rgba(fg.r, fg.g, fg.b, 0.15)
    readonly property color dimmedFg: Qt.rgba(fg.r, fg.g, fg.b, 0.55)

    // Bar
    readonly property int barHeight: 30
    readonly property int barMargin: 5
    readonly property int barRadius: 4
    readonly property color barBg: Qt.rgba(0, 0, 0, 0.5)
    readonly property color barFg: "#FFFFFF"
    readonly property int modulePadH: 12

    readonly property string wallpaper: Quickshell.env("HOME") + "/.nixos/wallpapers/pixel_1.png"

    // Exact fontconfig family name — Qt does not fuzzy-match.
    readonly property string fontFamily: "GeistMono Nerd Font Propo"
    readonly property int fontSize: 15
    readonly property int fontWeight: 400

    // Toasts
    readonly property int toastRadius: 12
    readonly property int toastPadding: 14
    readonly property int toastMargin: 18
    readonly property int toastTimeout: 5000

    // Picker overlay
    readonly property int pickerRadius: 12
}
