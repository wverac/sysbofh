#!/usr/bin/env bash
tailscale_status=$(tailscale status --json | jq -r '.Self.Online')
exitnode_status=$(tailscale status --json | jq -r '.ExitNodeStatus.Online')

if [[ "$tailscale_status" == "true" && "$exitnode_status" == "true" ]]; then
  echo -n " ❯"
else
  echo -n " ❯"
fi
