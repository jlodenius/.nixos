import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "."

// Generic bottom-notch fuzzy picker. Consumers set `items` ({label, ...},
// or {divider: true, label} section headers) and handle onEnter; optional
// glyph/subtitle fields decorate the rows. Set onEnterText to accept raw
// typed input: Shift+Enter always submits it, plain Enter submits it when
// freeText is true (e.g. nothing matched).
PanelWindow {
    id: root

    property bool open: false
    signal closeRequested()
    property string placeholder: ""
    property var items: []
    property string subtitleField: ""
    // Per-item colored status glyph (a Nerd Font char) at the row's left;
    // its color comes from glyphColorField (a color value on the item).
    property string glyphField: ""
    property string glyphColorField: ""
    property var onEnter: function(item) {}
    property var onEnterText: null
    property bool freeText: false

    property string query: search ? search.text : ""
    property int selectedIndex: 0

    // `active` keeps the window alive through the close animation.
    property bool active: false
    visible: active

    onOpenChanged: {
        if (open) {
            closeDelay.stop()
            active = true
            // Reset here, not in onActiveChanged: reopening during the close
            // animation leaves `active` true, which would keep a stale query.
            search.text = ""
            selectedIndex = firstSelectable()
            search.forceActiveFocus()
        } else {
            closeDelay.restart()
        }
    }
    Timer { id: closeDelay; interval: 300; onTriggered: root.active = false }

    onQueryChanged: selectedIndex = firstSelectable()

    // First non-divider row — so selection never starts on a section header.
    function firstSelectable() {
        for (let i = 0; i < filtered.length; i++)
            if (!filtered[i] || !filtered[i].divider) return i
        return 0
    }

    readonly property var filtered: {
        const q = query.trim().toLowerCase()
        if (q.length === 0) return items
        // While searching, drop section dividers — they're only meaningful
        // in the unfiltered, grouped view. Rank: label prefix > label
        // substring > subtitle (URL) substring, so a label match always
        // beats an incidental URL match.
        const pre = [], mid = [], sub = []
        for (let i = 0; i < items.length; i++) {
            const it = items[i]
            if (it.divider) continue
            const label = String(it.label || "").toLowerCase()
            const subText = subtitleField && it[subtitleField] ? String(it[subtitleField]).toLowerCase() : ""
            if (label.startsWith(q)) pre.push(it)
            else if (label.indexOf(q) >= 0) mid.push(it)
            else if (subText && subText.indexOf(q) >= 0) sub.push(it)
        }
        return pre.concat(mid, sub)
    }

    // Move selection by `dir`, skipping non-selectable divider rows.
    function step(dir) {
        const n = filtered.length
        if (n === 0) return
        let i = selectedIndex + dir
        while (i >= 0 && i < n && filtered[i] && filtered[i].divider) i += dir
        if (i >= 0 && i < n) selectedIndex = i
    }

    function activate() {
        if (freeText) { submitText(); return }
        if (filtered.length === 0) return
        const idx = Math.max(0, Math.min(selectedIndex, filtered.length - 1))
        const item = filtered[idx]
        if (item && item.divider) return
        onEnter(item)
        closeRequested()
    }

    function submitText() {
        if (!onEnterText) return
        const text = query.trim()
        if (text.length === 0) return
        onEnterText(text)
        closeRequested()
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-picker"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: dim
        anchors.fill: parent
        color: "#000000"
        opacity: root.open ? 0.35 : 0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Keys.onEscapePressed: root.closeRequested()
        MouseArea {
            anchors.fill: parent
            onClicked: root.closeRequested()
        }
    }

    Rectangle {
        id: notch
        anchors {
            bottom: parent.bottom
            bottomMargin: root.open ? 80 : -(height + 40)
            horizontalCenter: parent.horizontalCenter

            Behavior on bottomMargin {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.32, 0.72, 0.0, 1.0, 1.0, 1.0]
                }
            }
        }
        width: 720
        height: 420

        color: Theme.bg
        radius: Theme.pickerRadius
        border.color: Theme.hairline
        border.width: 1
        clip: true

        scale: root.open ? 1.0 : 0.96
        opacity: root.open ? 1.0 : 0.0
        Behavior on scale {
            NumberAnimation {
                duration: 190
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.26, 0.08, 0.25, 1.0, 1.0, 1.0]
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 190
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.26, 0.08, 0.25, 1.0, 1.0, 1.0]
            }
        }

        readonly property string sans: "sans-serif"

        Column {
            anchors.fill: parent

            Item {
                id: inputWrap
                width: parent.width
                height: 52

                Text {
                    id: searchIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: Theme.fg_muted
                    opacity: 0.85
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    renderType: Text.NativeRendering
                }

                TextField {
                    id: search
                    anchors.left: searchIcon.right
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    placeholderText: root.placeholder
                    color: Theme.fg
                    placeholderTextColor: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.5)
                    font.family: notch.sans
                    font.pixelSize: 16
                    background: null
                    padding: 8
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.closeRequested()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (event.modifiers & Qt.ShiftModifier) root.submitText()
                            else root.activate()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down
                                || (event.key === Qt.Key_J && (event.modifiers & Qt.ControlModifier))) {
                            root.step(1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up
                                || (event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier))) {
                            root.step(-1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_W && (event.modifiers & Qt.ControlModifier)) {
                            // Delete word before cursor (vim style).
                            const pos = search.cursorPosition
                            const t = search.text
                            let i = pos
                            while (i > 0 && /\s/.test(t[i - 1])) i--
                            while (i > 0 && !/\s/.test(t[i - 1])) i--
                            search.text = t.slice(0, i) + t.slice(pos)
                            search.cursorPosition = i
                            event.accepted = true
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.hairline
                }
            }

            ListView {
                id: list
                width: parent.width
                height: parent.height - inputWrap.height
                clip: true
                model: root.filtered
                currentIndex: root.selectedIndex
                spacing: 2
                topMargin: 10
                bottomMargin: 10
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                }

                delegate: Item {
                    id: rowItem
                    required property var modelData
                    required property int index
                    property bool isDivider: !!(modelData && modelData.divider)
                    width: list.width
                    height: isDivider ? 29 : 36

                    // ListView owns delegate x/y — the inset highlight must be
                    // an inner rectangle, never an x-offset on the root.
                    Rectangle {
                        visible: !rowItem.isDivider
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        radius: 8
                        color: rowItem.index === root.selectedIndex ? Theme.selection
                             : rowHover.hovered ? Theme.surface
                             : "transparent"
                    }

                    HoverHandler { id: rowHover; enabled: !rowItem.isDivider }

                    // Non-selectable section heading.
                    Text {
                        visible: rowItem.isDivider
                        anchors.left: parent.left
                        anchors.leftMargin: 22
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        text: rowItem.modelData ? String(rowItem.modelData.label || "") : ""
                        color: Theme.fg_muted
                        font.family: notch.sans
                        font.pixelSize: 11
                        font.weight: 600
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 0.6
                        renderType: Text.NativeRendering
                    }

                    Text {
                        id: rowGlyph
                        readonly property bool active: !rowItem.isDivider && root.glyphField.length > 0
                            && rowItem.modelData && String(rowItem.modelData[root.glyphField] || "").length > 0
                        visible: active
                        anchors.left: parent.left
                        anchors.leftMargin: 22
                        anchors.verticalCenter: parent.verticalCenter
                        text: active ? String(rowItem.modelData[root.glyphField]) : ""
                        color: (root.glyphColorField && rowItem.modelData && rowItem.modelData[root.glyphColorField])
                            ? rowItem.modelData[root.glyphColorField] : Theme.fg_muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        renderType: Text.NativeRendering
                    }

                    Text {
                        visible: !rowItem.isDivider
                        anchors.left: rowGlyph.active ? rowGlyph.right : parent.left
                        anchors.leftMargin: rowGlyph.active ? 10 : 22
                        anchors.right: subtitleText.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: rowItem.modelData ? String(rowItem.modelData.label || "?") : "?"
                        color: Theme.fg
                        font.family: notch.sans
                        font.pixelSize: 14
                        font.weight: 500
                        renderType: Text.NativeRendering
                        elide: Text.ElideRight
                    }
                    Text {
                        id: subtitleText
                        visible: !rowItem.isDivider && root.subtitleField && rowItem.modelData && (rowItem.modelData[root.subtitleField] || "").length > 0
                        text: rowItem.modelData && root.subtitleField ? String(rowItem.modelData[root.subtitleField] || "") : ""
                        color: Theme.fg_muted
                        font.family: notch.sans
                        font.pixelSize: 12
                        renderType: Text.NativeRendering
                        // Cap long subtitles (e.g. URLs) so they can't crowd
                        // out the label.
                        width: Math.min(implicitWidth, rowItem.width * 0.5)
                        elide: Text.ElideRight
                        anchors.right: parent.right
                        anchors.rightMargin: 22
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !rowItem.isDivider
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedIndex = rowItem.index
                            root.activate()
                        }
                    }
                }

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            }
        }
    }
}
