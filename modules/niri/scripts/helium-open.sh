#!/usr/bin/env bash
# Open a URL in Helium (sent to the running instance, or launches it), then
# focus the Helium window.
set -euo pipefail

target="${1:?usage: helium-open.sh <url>}"

niri msg action spawn -- helium "$target"

# Already in a Helium window: the tab opens there, don't yank focus elsewhere.
focused=$(niri msg -j windows 2>/dev/null \
      | jq -r '.[] | select(.is_focused and .app_id == "helium") | .id // empty') || focused=""
[ -n "$focused" ] && exit 0

for _ in 1 2 3 4 5; do
  id=$(niri msg -j windows 2>/dev/null \
        | jq -r '[.[] | select(.app_id == "helium")] | sort_by(.id) | .[0].id // empty') || id=""
  if [ -n "$id" ]; then
    niri msg action focus-window --id "$id"
    break
  fi
  sleep 0.2
done
