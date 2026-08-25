#!/usr/bin/env bash

WINDOW=$(niri msg --json windows 2>/dev/null | python3 -c '
import json, sys

try:
    windows = [w for w in json.load(sys.stdin) if w.get("title") == "mlqs"]
except Exception:
    windows = []

if windows:
    def timestamp(window):
        value = window.get("focus_timestamp") or {}
        return value.get("secs", 0), value.get("nanos", 0)

    window = max(windows, key=timestamp)
    print(window["id"], window["workspace_id"], int(window.get("is_focused", False)))
')

if [ -z "$WINDOW" ]; then
    exec mlqs-client
fi

read -r WINDOW_ID WINDOW_WORKSPACE IS_FOCUSED <<<"$WINDOW"

if [ "$IS_FOCUSED" = "1" ]; then
    TARGET=$(niri msg --json workspaces | python3 -c '
import json, sys

workspaces = json.load(sys.stdin)
window_workspace = int(sys.argv[1])
output = next(w["output"] for w in workspaces if w["id"] == window_workspace)
print(max(w["idx"] for w in workspaces if w["output"] == output))
' "$WINDOW_WORKSPACE")
    niri msg action move-window-to-workspace "$TARGET" --window-id "$WINDOW_ID" --focus false
    exit
fi

TARGET=$(niri msg --json workspaces | python3 -c '
import json, sys

workspace = next(w for w in json.load(sys.stdin) if w.get("is_focused"))
print(workspace.get("name") or workspace["idx"])
')
niri msg action move-window-to-workspace "$TARGET" --window-id "$WINDOW_ID" --focus false
niri msg action focus-window --id "$WINDOW_ID"
