#\!/usr/bin/env bash
if ifconfig ipsec0 2>/dev/null | grep -q "inet "; then
  echo -n " ❯"
else
  echo -n " ❯"
fi
