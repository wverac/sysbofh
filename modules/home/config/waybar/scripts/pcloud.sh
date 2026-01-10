#!/usr/bin/env bash

# Check if pCloud is running
if ! pgrep -x pcloud &>/dev/null; then
    echo '{"text": "󰅤 ", "class": "pcloud-off", "tooltip": "pCloud is not running"}'
    exit 0
fi

# Check if drive is mounted
if ! mountpoint -q ~/pCloudDrive 2>/dev/null; then
    echo '{"text": "󰅤 ", "class": "pcloud-off", "tooltip": "pCloud drive not mounted"}'
    exit 0
fi

# Get disk usage
usage=$(df -h ~/pCloudDrive 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

# pCloud is running and mounted
echo "{\"text\": \"󰅟 \", \"class\": \"pcloud-on\", \"tooltip\": \"pCloud: $usage\"}"
