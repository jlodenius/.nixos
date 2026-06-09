#!/usr/bin/env bash
set -euo pipefail

BOOKMARKS="$HOME/.config/net.imput.helium/Default/Bookmarks"
QUICKMARKS="$HOME/.config/helium-palette/quickmarks"
FUZZEL_CONF="$HOME/.config/niri/scripts/palette-fuzzel.ini"

choice=$(
  {
    [ -r "$QUICKMARKS" ] && cat "$QUICKMARKS"
    [ -r "$BOOKMARKS" ] && jq -r '.roots | .. | objects | select(.type == "url") | "\(.name)\t\(.url)"' "$BOOKMARKS"
  } | fuzzel --dmenu --config "$FUZZEL_CONF"
) || exit 0

[ -n "$choice" ] || exit 0

url=${choice##*$'\t'}
exec helium "$url"
