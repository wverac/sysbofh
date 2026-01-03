#!/usr/bin/env bash

IVPN_BIN="$(command -v ivpn)"

# If ivpn is missing, VPN is off
[[ -x "$IVPN_BIN" ]] || {
  echo -n "󰦞"
  exit 0
}

# Check ivpn status - get VPN line and check for DISCONNECTED
vpn_state="$("$IVPN_BIN" status 2>/dev/null | grep "^VPN" | awk -F': ' '{print $2}')"

if [[ "$vpn_state" == "DISCONNECTED" ]]; then
  echo -n "󰦞"
else
  echo -n "󰖂"
fi

exit 0
