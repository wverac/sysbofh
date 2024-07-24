#!/usr/bin/env bash

if tailscale status &>/dev/null; then
  if tailscale exit-node list | grep -q selected; then
    tooltip=$(tailscale exit-node list | grep selected | awk '{print $2" "$3}')
    echo "{\"text\": \" \", \"class\": \"vpn-on\", \"tooltip\": \"$tooltip\"}"
  else
    echo '{"text": " ", "class": "vpn-off"}'
  fi
else
  echo '{"text": " ", "class": "vpn-off"}'
fi
