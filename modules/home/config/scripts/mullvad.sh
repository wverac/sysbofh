#!/usr/bin/env bash

MULLVAD_BIN="$(command -v mullvad)"

# If mullvad is missing, VPN is off
[[ -x "$MULLVAD_BIN" ]] || {
  echo -n "󰦞"
  exit 0
}

# Check mullvad status - the first line carries the tunnel state
vpn_state="$("$MULLVAD_BIN" status 2>/dev/null | head -n 1 | awk '{print $1}')"

if [[ "$vpn_state" != "Connected" ]]; then
  echo -n "󰦞"
else
  echo -n "󰖂"
fi

exit 0
