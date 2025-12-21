#!/usr/bin/env bash
# Check for WireGuard-based VPN (ProtonVPN uses utun interfaces)
# VPN is connected if default route goes through a utun with an inet address

VPN_IFACE=$(netstat -rn 2>/dev/null | awk '/^default.*utun/ {print $NF; exit}')

if [[ -n "$VPN_IFACE" ]] && ifconfig "$VPN_IFACE" 2>/dev/null | grep -q "inet "; then
  echo -n " ❯"
else
  echo -n " ❯"
fi
