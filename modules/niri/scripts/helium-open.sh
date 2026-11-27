#!/usr/bin/env bash
set -euo pipefail

if (($# == 0)); then
  exec helium
fi

urls=()
for target in "$@"; do
  case "$target" in
    http://*|https://*|file://*) urls+=("$target") ;;
    *)
      if [[ "$target" =~ ^[a-zA-Z][a-zA-Z0-9+.-]*: ]]; then
        exec helium -- "$@"
      fi
      path=$(realpath -ms -- "$target")
      urls+=("file://$(jq -rn --arg path "$path" '$path | split("/") | map(@uri) | join("/")')")
      ;;
  esac
done

# This ID is derived from the public key in the routing extension's manifest.
payload=$(printf '%s\0' "${urls[@]}" | jq -sRr 'split("\u0000")[:-1] | @json | @uri')
exec helium -- "chrome-extension://ihccmmfpcfgdkijdbgbfpmjjppkjcgbi/open.html#$payload"
