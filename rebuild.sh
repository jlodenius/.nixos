#!/usr/bin/env bash

set -e # Exit on any individual command failure

# 1. Ensure we are in the dotfiles directory
cd "$HOME/.nixos"

# 2. Stage all files (Important: Flakes ignore untracked files!)
# This handles new files so the build doesn't fail on "file not found"
git add -A

# 3. Format with Alejandra
echo "🎨 Formatting..."
alejandra . &>/dev/null || (alejandra . ; echo "Formatting failed!" && exit 1)

# 4. Check for actual changes
# If nothing changed after formatting, no need to rebuild
if git diff --quiet HEAD; then
    echo "✨ No changes detected, exiting."
    exit 0
fi

# 5. Show the diff to the user
git diff -U0 HEAD

echo "🚀 NixOS Rebuilding..."

# 6. The Build Command
# We use 'tee' so you can see the progress live, while still logging to a file.
# The PIPESTATUS[0] trick captures the exit code of nixos-rebuild, not tee.
sudo nixos-rebuild switch --flake . 2>&1 | tee nixos-switch.log
BUILD_EXIT_CODE=${PIPESTATUS[0]}

# 7. Post-build Logic
if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "❌ Build failed! Recent errors:"
    grep --color -i "error" nixos-switch.log || tail -n 20 nixos-switch.log
    exit 1
fi

# 8. Commit the changes on success
gen=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | grep current | awk '{print $1}')

msg="Generation $gen: $(date +'%Y-%m-%d %H:%M:%S')"

echo "📝 Committing: $msg"
git commit -am "$msg"

# 9. Cleanup
rm nixos-switch.log

echo "✅ Done! System is now at generation $gen."
