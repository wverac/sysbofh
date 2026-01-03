#!/usr/bin/env bash

IVPN_BIN="$(command -v ivpn)"

# If ivpn is missing, VPN is off
[[ -x "$IVPN_BIN" ]] || {
  echo -n "󰦞"
  exit 0
}

# Check ivpn status
status_output="$("$IVPN_BIN" status 2>/dev/null)"

# Check if connected
if echo "$status_output" | grep -qi "connected"; then
  echo -n "󰖂"
else
  echo -n "󰦞"
fi

exit 0
