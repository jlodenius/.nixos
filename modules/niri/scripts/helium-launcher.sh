#!/usr/bin/env bash
set -euo pipefail

QUICKMARKS="$HOME/.config/helium-launcher/quickmarks"
NIX_BOOKMARKS="$HOME/.config/helium-launcher/bookmarks"
FUZZEL_CONF="$HOME/.config/niri/scripts/helium-launcher-fuzzel.ini"

# Candidate list ("name<TAB>url" lines): Nix-managed quickmarks + bookmarks only.
# Helium's native bookmark store is intentionally ignored.
choice=$(
  {
    [ -r "$QUICKMARKS" ] && cat "$QUICKMARKS"
    [ -r "$NIX_BOOKMARKS" ] && cat "$NIX_BOOKMARKS"
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
# Helium.
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
