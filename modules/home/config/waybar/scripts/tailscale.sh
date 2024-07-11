#!/usr/bin/env bash

if tailscale status &>/dev/null; then
  if tailscale exit-node list | grep -q selected; then
    echo '{"text": " ", "class": "vpn-on"}'
  else
    echo '{"text": " ", "class": "vpn-off"}'
  fi
else
  echo '{"text": " ", "class": "vpn-off"}'
fi

