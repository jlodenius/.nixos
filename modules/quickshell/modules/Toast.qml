import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "."

Rectangle {
    id: root

    required property var notification

    property bool shown: false
    property bool dismissing: false
    property bool collapsed: false

    opacity: (shown && !dismissing && !collapsed) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // Never animate height: it propagates to the PanelWindow's
    // implicitHeight, and per-frame layer-shell resizes render at ~10fps.
    // Fade first, snap the height once fully invisible. Fully-collapsed
    // toasts also go invisible so the overlay window can hide (it would
    // otherwise sit as a transparent strip swallowing clicks).
    height: (collapsed && opacity === 0) ? 0 : implicitHeight
    visible: !(collapsed && opacity === 0)
    clip: true

    // Never flash a toast for one that's already seen (arrived while focused on
    // its source) or restored across a quickshell reload (isSeen covers the
    // restored case: ids absent from liveIds count as seen).
    Component.onCompleted: { shown = true; if (Notifications.isSeen(notification) || !Notifications.startupSettled || (notification && Notifications.mutedIds[notification.id])) collapsed = true }

    Connections {
        target: Notifications
        function onSeenGenChanged() {
            if (Notifications.isSeen(root.notification)) root.collapsed = true
        }
    }

    function beginDismiss() {
        if (dismissing) return
        dismissing = true
    }

    Timer {
        id: dismissDelay
        running: root.dismissing
        interval: 220
        onTriggered: if (notification) notification.dismiss()
    }

    readonly property bool isCritical: notification && notification.urgency === NotificationUrgency.Critical
    readonly property real effectiveTimeout: {
        if (!notification) return Theme.toastTimeout
        if (isCritical) return 30000
        const t = notification.expireTimeout
        if (t === 0) return 0   // spec: explicit never-expire
        if (t < 0) return Theme.toastTimeout
        return t
    }

    implicitWidth: 360
    implicitHeight: content.implicitHeight + Theme.toastPadding * 2

    color: Theme.bg
    radius: Theme.toastRadius
    border.color: isCritical ? Theme.red : Theme.surface
    border.width: 1

    Row {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.toastPadding
        }
        spacing: 10

        // Sender avatar from the image hint, else the app's themed icon;
        // hidden unless something actually loads.
        ClippingRectangle {
            id: avatar
            readonly property string src: {
                const n = root.notification
                if (!n) return ""
                const p = n.image || ""
                if (p) return p.startsWith("/") ? "file://" + p : p
                return n.appIcon ? Quickshell.iconPath(n.appIcon, true) : ""
            }
            visible: avatarImg.status === Image.Ready
            width: visible ? 40 : 0
            height: 40
            radius: width / 2
            color: "transparent"

            Image {
                id: avatarImg
                anchors.fill: parent
                source: avatar.src
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 80
                sourceSize.height: 80
                smooth: true
                cache: true
            }
        }

        Column {
            width: parent.width - (avatar.visible ? avatar.width + content.spacing : 0)
            spacing: 4

            Text {
                width: parent.width
                text: notification ? (notification.appName || "Notification") : ""
                color: Theme.fg_muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: notification ? notification.summary : ""
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.weight: 600
                renderType: Text.NativeRendering
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
            }

            Text {
                width: parent.width
                visible: text.length > 0
                text: notification ? notification.body : ""
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                renderType: Text.NativeRendering
                // Notification body-markup is HTML-ish (<b>, <i>, <a>) —
                // StyledText renders it; Markdown would show raw tags.
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 5
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.beginDismiss()
    }

    Timer {
        running: effectiveTimeout > 0 && !root.dismissing && !root.collapsed
        interval: effectiveTimeout
        // Chat apps (Slack/Discord/Teams) collapse but stay tracked, so the
        // Mod+i center keeps them as history. Everything else drops once its
        // toast times out.
        onTriggered: {
            if (Notifications.isMessageApp(root.notification)) root.collapsed = true
            else root.beginDismiss()
        }
    }
}
