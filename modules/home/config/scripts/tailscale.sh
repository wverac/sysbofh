#!/usr/bin/env bash

# This indicator intentionally checks only this node's Tailscale connectivity.
# IVPN owns the default route and the NixOS module explicitly disables exit nodes.

set -o nounset
set -o pipefail

readonly ONLINE_ICON=""
readonly OFFLINE_ICON=""

offline() {
  printf '%s' "$OFFLINE_ICON"
  exit 0
}

tailscale_bin="$(command -v tailscale 2>/dev/null || true)"
jq_bin="$(command -v jq 2>/dev/null || true)"
timeout_bin="$(command -v timeout 2>/dev/null || true)"

# Fail closed: a missing dependency or an unresponsive daemon is offline.
[[ -x "$tailscale_bin" && -x "$jq_bin" && -x "$timeout_bin" ]] || offline

# Excluding peers keeps the response small. The one-second limit remains below
# Starship's two-second command timeout and prevents a blocked daemon from
# delaying every prompt.
status="$("$timeout_bin" 1s "$tailscale_bin" status --json --peers=false 2>/dev/null)" || offline
[[ -n "$status" ]] || offline

if printf '%s' "$status" | "$jq_bin" -e '
  type == "object"
  and .BackendState == "Running"
  and ((.Self | type) == "object")
  and .Self.Online == true
' >/dev/null 2>&1; then
  printf '%s' "$ONLINE_ICON"
else
  offline
fi
