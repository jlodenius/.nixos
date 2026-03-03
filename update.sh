#!/usr/bin/env bash
set -e

# 1. Configuration
CONF_DIR="$HOME/.nixos"
TARGET_HOST="${1:-$(hostname)}"

cd "$CONF_DIR"

# 2. Safety Check
if [ ! -d "./hosts/$TARGET_HOST" ]; then
    echo "Error: Configuration for host '$TARGET_HOST' not found in ./hosts/"
    exit 1
fi

echo "Updating flake inputs..."

# 3. Update flake.lock with latest versions
nix flake update

# 4. Show what changed
echo ""
echo "Changes to flake.lock:"
git diff flake.lock

# 5. Ask to rebuild
echo ""
read -p "Rebuild now? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    exec "$CONF_DIR/rebuild.sh" "$TARGET_HOST"
fi
