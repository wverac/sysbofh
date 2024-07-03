#!/usr/bin/env bash

if tailscale exit-node list | grep selected &>/dev/null; then
  echo '{"text": " ", "class": "vpn-on"}'
else
  echo '{"text": " ", "class": "vpn-off"}'
fi
