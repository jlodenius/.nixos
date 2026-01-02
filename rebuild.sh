#!/usr/bin/env bash
set -e

# 1. Configuration & Detection
CONF_DIR="$HOME/.nixos"
# If an argument is passed, use it as the host. Otherwise, use current hostname.
TARGET_HOST="${1:-$(hostname)}"

cd "$CONF_DIR"

# 2. Safety Check
# Ensure the folder for this host actually exists in your structure
if [ ! -d "./hosts/$TARGET_HOST" ]; then
    echo "❌ Error: Configuration for host '$TARGET_HOST' not found in ./hosts/"
    exit 1
fi

echo "🖥️  Targeting Host: $TARGET_HOST"

# 3. Stage files
git add -A

# 4. Format
echo "🎨 Formatting..."
alejandra . &>/dev/null || (alejandra . ; echo "Formatting failed!" && exit 1)

# 5. Check for changes
if git diff --quiet HEAD; then
    echo "✨ No changes detected, exiting."
    exit 0
fi

git diff -U0 HEAD

echo "🚀 NixOS Rebuilding for $TARGET_HOST..."

# 6. The Build Command (Updated with the specific host)
# The .#${TARGET_HOST} matches your nixosConfigurations list
sudo nixos-rebuild switch --flake ".#$TARGET_HOST" 2>&1 | tee nixos-switch.log
BUILD_EXIT_CODE=${PIPESTATUS[0]}

# 7. Post-build Logic
if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 8. Commit
gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current | awk '{print $1}')
msg="Host $TARGET_HOST | Gen $gen: $(date +'%Y-%m-%d %H:%M:%S')"

echo "📝 Committing: $msg"
git commit -am "$msg"

rm nixos-switch.log
echo "✅ Done! $TARGET_HOST is now at generation $gen."
