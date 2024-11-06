#!/usr/bin/env bash

if  mullvad status | grep -q Connected; then
    vpnserver="$(mullvad status | grep Relay | awk '{print $2}')"
    echo -n "  $vpnserver"
  else
    vpnerror="VPN Disconnected"
    echo -n "  $vpnerror"
  fi
