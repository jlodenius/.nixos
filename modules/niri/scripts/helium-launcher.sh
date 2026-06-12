#!/usr/bin/env bash
set -euo pipefail

QUICKMARKS="$HOME/.config/helium-launcher/quickmarks"
NIX_BOOKMARKS="$HOME/.config/helium-launcher/bookmarks"
FUZZEL_CONF="$HOME/.config/fuzzel/helium-launcher.ini"

# Candidate list: Nix-managed quickmarks + bookmarks only (Helium's native
# bookmark store is intentionally ignored). Source files are authored as
# "<label> <url>" per line, with blank lines and '#' comments allowed for
# grouping. format() drops those and emits "label<TAB>url" — the tab is a
# sentinel that distinguishes a picked entry from raw typed input below.
format() {
  [ -r "$1" ] || return 0
  awk '
    /^[[:space:]]*#/ { next }   # comment line
    /^[[:space:]]*$/ { next }   # blank line
    {
      url = $NF                 # URL is the last whitespace-separated field
      $NF = ""                  # remainder (collapsed) is the label
      sub(/[[:space:]]+$/, "")
      printf "%s\t%s\n", $0, url
    }
  ' "$1"
}

choice=$(
  {
    format "$QUICKMARKS"
    format "$NIX_BOOKMARKS"
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
