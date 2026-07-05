#!/usr/bin/env bash

status=$(tailscale status --json 2>/dev/null) || status=""

if jq -e '.BackendState == "Running" and .Self.Online == true' <<<"$status" &>/dev/null; then
  hostname=$(jq -r '.Self.HostName // "Tailscale"' <<<"$status")
  echo "{\"text\": \" \", \"class\": \"vpn-on\", \"tooltip\": \"Tailscale connected: $hostname\"}"
else
  echo '{"text": " ", "class": "vpn-off", "tooltip": "Tailscale is not connected"}'
fi
