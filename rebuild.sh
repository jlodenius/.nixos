#!/usr/bin/env bash
set -e

# 1. Configuration & Detection
CONF_DIR="$HOME/.nixos"
TARGET_HOST="${1:-$(hostname)}"

cd "$CONF_DIR"

# 2. Safety Check
if [ ! -d "./hosts/$TARGET_HOST" ]; then
    echo "Error: Configuration for host '$TARGET_HOST' not found in ./hosts/"
    exit 1
fi

echo "Targeting Host: $TARGET_HOST"

# 3. Format and stage files
echo "Formatting..."
if ! alejandra . &>/dev/null; then
    echo "Formatting failed!"
    alejandra .
    exit 1
fi
git add -A

# 4. Build and compare the desired system
echo "Checking system closure..."
desired=$(nix build ".#nixosConfigurations.${TARGET_HOST}.config.system.build.toplevel" --no-link --print-out-paths)
desired=$(readlink -f "$desired")
current=$(readlink -f /run/current-system)

if [ "$desired" = "$current" ]; then
    echo "System is already up to date."
else
    echo "NixOS Rebuilding for $TARGET_HOST..."
    sudo nixos-rebuild switch --flake ".#$TARGET_HOST"
fi

# 5. Commit staged changes
gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current | awk '{print $1}')

if ! git diff --cached --quiet; then
    msg="Host $TARGET_HOST | Gen $gen: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Committing: $msg"
    git commit -m "$msg"
else
    echo "No changes to commit."
fi

echo "Done! $TARGET_HOST is now at generation $gen."
