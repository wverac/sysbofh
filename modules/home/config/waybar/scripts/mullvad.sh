#!/usr/bin/env bash

status=$(mullvad status --json 2>/dev/null) || status=""
state=$(jq -r '.state // empty' <<<"$status" 2>/dev/null)

case "$state" in
connected)
  relay=$(jq -r '.details.location.hostname // "Mullvad"' <<<"$status")
  city=$(jq -r '.details.location.city // empty' <<<"$status")
  country=$(jq -r '.details.location.country // empty' <<<"$status")
  echo "{\"text\": \"󰖂\", \"class\": \"vpn-on\", \"tooltip\": \"Mullvad connected: $relay ($city, $country)\"}"
  ;;
error)
  # The daemon drops all traffic in this state, so surface the reason
  reason=$(mullvad status 2>/dev/null | head -n 1)
  echo "{\"text\": \"󰦞\", \"class\": \"vpn-off\", \"tooltip\": \"Mullvad is blocking traffic: ${reason:-unknown reason}\"}"
  ;;
connecting | disconnecting)
  echo "{\"text\": \"󰦞\", \"class\": \"vpn-off\", \"tooltip\": \"Mullvad is $state\"}"
  ;;
*)
  echo "{\"text\": \"󰦞\", \"class\": \"vpn-off\", \"tooltip\": \"Mullvad is not connected\"}"
  ;;
esac
