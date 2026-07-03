import QtQuick
import "."

// Shared text style for bar modules; override color/size per use.
Text {
    color: Theme.barFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
    font.hintingPreference: Font.PreferFullHinting
    renderType: Text.NativeRendering
}
