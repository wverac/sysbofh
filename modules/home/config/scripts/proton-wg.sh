#!/usr/bin/env bash

IFACE="protonvpn"
MAX_AGE=600

WG_BIN="$(command -v wg)"

# If wg is missing, VPN is off
[[ -x "$WG_BIN" ]] || {
  echo -n "󰦞"
  exit 0
}

# Read handshake
hs_epoch="$(sudo -n "$WG_BIN" show "$IFACE" latest-handshakes 2>/dev/null | awk 'NR==1 {print $2}')"

# No data, not connected
[[ -n "$hs_epoch" && "$hs_epoch" != "0" ]] || {
  echo -n "󰦞"
  exit 0
}

now="$(date +%s)"
age=$((now - hs_epoch))

if ((age <= MAX_AGE)); then
  echo -n "󰖂"
else
  echo -n "󰦞"
fi

exit 0
