import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "qs-wallpaper"
    color: "black"

    Image {
        anchors.fill: parent
        source: "file://" + Theme.wallpaper
        fillMode: Image.PreserveAspectCrop
    }
}
