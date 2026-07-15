#!/usr/bin/env bash
# Jump to a window if it exists, otherwise launch the app
# Jumps to most recently active window, then cycles through others
# Usage: niri-jump-or-exec <app-id-or-title-pattern> <command>
# If app-id starts with "title:" it matches against window title instead

APP_ID="$1"
COMMAND="$2"
CYCLE_STATE="/tmp/niri-cycle-${APP_ID}"

if [ -z "$APP_ID" ] || [ -z "$COMMAND" ]; then
    echo "Usage: niri-jump-or-exec <app-id-or-title-pattern> <command>"
    exit 1
fi

MATCH_BY_TITLE=false
MATCH_BY_REGEX=false
PATTERN="$APP_ID"
if [[ "$APP_ID" == title:* ]]; then
    MATCH_BY_TITLE=true
    PATTERN="${APP_ID#title:}"
elif [[ "$APP_ID" == regex:* ]]; then
    MATCH_BY_REGEX=true
    PATTERN="${APP_ID#regex:}"
fi

CURRENT_FOCUSED=$(niri msg --json windows | python3 -c "
import sys, json
for w in json.load(sys.stdin):
    if w.get('is_focused', False):
        print(w['id']); break
")

RESULT=$(niri msg --json windows | python3 -c "
import sys, json, re
try:
    windows = json.load(sys.stdin)
    match_by_title = '$MATCH_BY_TITLE' == 'true'
    match_by_regex = '$MATCH_BY_REGEX' == 'true'
    pattern = '$PATTERN'

    if match_by_title:
        matching_windows = [w for w in windows if re.search(pattern, w.get('title', ''), re.IGNORECASE)]
    elif match_by_regex:
        matching_windows = [w for w in windows if re.search(pattern, w.get('app_id', '') or '')]
    else:
        matching_windows = [w for w in windows if w.get('app_id') == pattern]

    if not matching_windows:
        print('NONE'); sys.exit(0)

    def ts(w):
        ft = w.get('focus_timestamp') or {}
        return (ft.get('secs') or 0, ft.get('nanos') or 0)
    matching_windows.sort(key=ts, reverse=True)

    current_focused_id = '$CURRENT_FOCUSED'
    focused_idx = -1
    for idx, w in enumerate(matching_windows):
        if str(w['id']) == current_focused_id:
            focused_idx = idx; break

    if focused_idx >= 0:
        next_idx = (focused_idx + 1) % len(matching_windows)
        print(matching_windows[next_idx]['id'])
    else:
        last_cycled = None
        try:
            with open('$CYCLE_STATE', 'r') as f:
                last_cycled = f.read().strip()
        except: pass
        if last_cycled:
            for w in matching_windows:
                if str(w['id']) == last_cycled:
                    print(w['id']); sys.exit(0)
        print(matching_windows[0]['id'])
except Exception:
    print('ERROR'); sys.exit(1)
")

if [ "$RESULT" = "NONE" ]; then
    $COMMAND &
elif [ "$RESULT" = "ERROR" ]; then
    exit 1
else
    niri msg action focus-window --id "$RESULT"
    echo "$RESULT" > "$CYCLE_STATE"
fi
