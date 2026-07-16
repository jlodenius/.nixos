#!/usr/bin/env bash
# Re-dispatch a mail notification's action over the mlqs daemon socket, for
# history entries whose live D-Bus notification is already gone. The daemon
# keeps each notification's deep-link keyed by server id.
# usage: mlqs-notifact.sh <notification-id> [default|read]
[ -n "$1" ] || exit 1
python3 - "$1" "${2:-default}" << 'EOF'
import json, os, socket, sys
s = socket.socket(socket.AF_UNIX)
s.connect(os.environ["XDG_RUNTIME_DIR"] + "/mlqs.sock")
s.sendall((json.dumps({"type": "notifact", "id": str(sys.argv[1]), "text": sys.argv[2]}) + "\n").encode())
EOF
