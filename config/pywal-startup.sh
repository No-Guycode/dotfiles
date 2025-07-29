#!/bin/bash
if [ -f ~/.cache/wal/colors.sh ]; then
    wal -R -n -q
    pkill waybar 2>/dev/null || true
    sleep 1
    waybar &
    pkill -USR1 kitty 2>/dev/null || true
fi
