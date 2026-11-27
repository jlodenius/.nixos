#!/usr/bin/env bash
set -euo pipefail

if (($# == 0)); then
  exec helium
fi

# Niri assigns window IDs in creation order, regardless of focus history.
oldest=$(niri msg -j windows 2>/dev/null \
  | jq -r '[.[] | select(.app_id == "helium")] | min_by(.id) | .id // empty') || oldest=""

if [[ -n "$oldest" ]] && niri msg action focus-window --id "$oldest" 2>/dev/null; then
  for _ in {1..20}; do
    if niri msg -j focused-window 2>/dev/null | jq -e --argjson id "$oldest" '.id == $id' >/dev/null; then
      unset XDG_ACTIVATION_TOKEN DESKTOP_STARTUP_ID
      break
    fi
    sleep 0.05
  done
fi

exec helium -- "$@"
