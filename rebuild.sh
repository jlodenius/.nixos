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

switched=false
if [ "$desired" = "$current" ]; then
    echo "System is already up to date."
else
    echo "NixOS Rebuilding for $TARGET_HOST..."
    sudo nixos-rebuild switch --store-path "$desired"
    switched=true
fi

# 5. Commit staged changes
if ! git diff --cached --quiet; then
    gen=$(nixos-rebuild list-generations --json | jq -r '.[] | select(.current) | .generation')
    msg="Host $TARGET_HOST | Gen $gen: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "Committing: $msg"
    git commit -m "$msg"
else
    echo "No changes to commit."
fi

if $switched; then
    gen=${gen:-$(nixos-rebuild list-generations --json | jq -r '.[] | select(.current) | .generation')}
    echo "Done! $TARGET_HOST is now at generation $gen."
else
    echo "Done! No rebuild was needed."
fi
