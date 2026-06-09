#!/usr/bin/env bash
set -euo pipefail

BOOKMARKS="$HOME/.config/net.imput.helium/Default/Bookmarks"
QUICKMARKS="$HOME/.config/helium-palette/quickmarks"
FUZZEL_CONF="$HOME/.config/niri/scripts/palette-fuzzel.ini"

# Walk the bookmark tree, prefixing each entry with its lowercased folder path
# (e.g. "food/grill/Some Recipe"). Root containers (Bookmarks bar, Other) are
# not included in the path. Output is "label<TAB>url".
bookmarks_jq='
  def walk($prefix):
    (.children // [])[] as $c
    | if $c.type == "folder"
      then ($c | walk($prefix + ($c.name | ascii_downcase) + "/"))
      else "\($prefix)\($c.name)\t\($c.url)"
      end;
  .roots[] | walk("")
'

choice=$(
  {
    [ -r "$QUICKMARKS" ] && cat "$QUICKMARKS"
    [ -r "$BOOKMARKS" ] && jq -r "$bookmarks_jq" "$BOOKMARKS"
  } | fuzzel --dmenu --config "$FUZZEL_CONF"
) || exit 0

[ -n "$choice" ] || exit 0

# A selected bookmark/quickmark line contains a tab ("label<TAB>url") -> open its
# URL. Otherwise $choice is raw typed text (Shift+Enter / execute-input): open it
# as a URL if it looks like one, else search the default engine.
SEARCH_URL="https://duckduckgo.com/?q="

if [[ "$choice" == *$'\t'* ]]; then
  target=${choice##*$'\t'}
elif [[ "$choice" == *"://"* ]]; then
  target=$choice
elif [[ "$choice" != *[[:space:]]* && "$choice" == *.* ]]; then
  target="https://$choice"
else
  target="$SEARCH_URL$(jq -rn --arg q "$choice" '$q|@uri')"
fi

# Open the URL (sent to the running instance, or launches Helium), then focus
# Helium. A running instance won't raise its own window, so selecting a page you
# already have open would otherwise look like nothing happened.
niri msg action spawn -- helium "$target"

for _ in 1 2 3 4 5; do
  id=$(niri msg -j windows 2>/dev/null \
        | jq -r '[.[] | select(.app_id == "helium")] | sort_by(.id) | .[0].id // empty') || id=""
  if [ -n "$id" ]; then
    niri msg action focus-window --id "$id"
    break
  fi
  sleep 0.2
done
