#!/usr/bin/env bash

# Error handler function
failure() {
  local lineno=$1
  local msg=$2
  echo "------------------------------------------------"
  echo "❌ ERROR: Command failed at line $lineno"
  echo "Failed Command: $msg"
  echo "Exit Code: $?"
  echo "------------------------------------------------"
}

# Set the trap to catch errors (ERR)
trap 'failure ${BASH_LINENO[0]} "$BASH_COMMAND"' ERR

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

# 3. Stage files
git add -A

# 4. Format
echo "Formatting..."
alejandra . &>/dev/null || (alejandra . ; echo "Formatting failed!" && exit 1)

# 5. Check for changes
if git diff --quiet HEAD; then
    echo "No changes detected, exiting."
    exit 0
fi

echo "NixOS Rebuilding for $TARGET_HOST..."

# 6. The Build Command
sudo nixos-rebuild switch --flake ".#$TARGET_HOST"
BUILD_EXIT_CODE=$?

# 7. Post-build Logic
if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# 8. Commit
gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current | awk '{print $1}')
msg="Host $TARGET_HOST | Gen $gen: $(date +'%Y-%m-%d %H:%M:%S')"

echo "Committing: $msg"
git commit -am "$msg"

echo "Done! $TARGET_HOST is now at generation $gen."
