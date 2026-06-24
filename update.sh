#!/usr/bin/env bash
set -euo pipefail

SINGBOX_VERSION="1.12.25"
SINGBOX_URL="https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/sing-box-${SINGBOX_VERSION}-linux-amd64.tar.gz"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sing-box"
SINGBOX="${CACHE_DIR}/sing-box-${SINGBOX_VERSION}"

if [[ ! -x "$SINGBOX" ]]; then
  echo "Downloading sing-box ${SINGBOX_VERSION}..."
  mkdir -p "$CACHE_DIR"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "$SINGBOX_URL" | tar -xz -C "$tmp"
  mv "$tmp/sing-box-${SINGBOX_VERSION}-linux-amd64/sing-box" "$SINGBOX"
  chmod +x "$SINGBOX"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SINGBOX" rule-set compile \
  --output "$SCRIPT_DIR/twitch-ad-bypass.srs" \
  "$SCRIPT_DIR/twitch-ad-bypass.json"

echo "Compiled. Round-trip check:"
"$SINGBOX" rule-set decompile --output /dev/stdout "$SCRIPT_DIR/twitch-ad-bypass.srs" 2>/dev/null || true

cd "$SCRIPT_DIR"
git add twitch-ad-bypass.json twitch-ad-bypass.srs
git diff --cached --stat
if git diff --cached --quiet; then
  echo "No changes — rule-set is already up to date."
else
  git commit -m "update rule-set ($(date -u +%Y-%m-%d))"
  git push
fi
