pragma Singleton

import QtQuick
import Quickshell

// Melange palette — keep in sync with modules/colours.nix.
// Bar metrics/style mirror the old waybar config; toast style mirrors mako.
Singleton {
    id: theme

    // Base UI
    readonly property color bg: "#292522"
    readonly property color surface: "#34302C"
    readonly property color selection: "#403A36"
    readonly property color subtle: "#867462"
    readonly property color comment: "#C1A78E"
    readonly property color fg: "#ECE1D7"

    // Accents
    readonly property color red: "#D47766"
    readonly property color yellow: "#EBC06D"
    readonly property color green: "#85B695"
    readonly property color cyan: "#89B3B6"
    readonly property color blue: "#A3A9CE"
    readonly property color magenta: "#CF9BC2"

    readonly property color accent: yellow
    readonly property color fg_muted: comment
    readonly property color fg_subtle: subtle
    readonly property color hairline: Qt.rgba(fg.r, fg.g, fg.b, 0.15)
    readonly property color dimmedFg: Qt.rgba(fg.r, fg.g, fg.b, 0.55)

    // Bar (waybar: height 30, margin 5, radius 4, rgba(0,0,0,0.5), white text)
    readonly property int barHeight: 30
    readonly property int barMargin: 5
    readonly property int barRadius: 4
    readonly property color barBg: Qt.rgba(0, 0, 0, 0.5)
    readonly property color barFg: "#FFFFFF"
    readonly property int modulePadH: 12

    readonly property string fontFamily: "Geist Mono Nerd Font Propo"
    readonly property string iconFontFamily: "Geist Mono Nerd Font Propo"
    readonly property int fontSize: 15
    readonly property int fontWeight: 600

    // Toasts (mako: bg background, border surface, radius 12, padding 14,
    // margin 18, default-timeout 5000, critical border red)
    readonly property int toastRadius: 12
    readonly property int toastPadding: 14
    readonly property int toastMargin: 18
    readonly property int toastTimeout: 5000

    // Picker overlay
    readonly property int pickerRadius: 12
}
