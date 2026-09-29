#!/usr/bin/env bash
ss -ltn | grep -E ':5900|:3389|:2323'
echo ---
pgrep -af x11vnc
echo ---
pgrep -af xmessage
echo ---
# verify VNC-PARITY-OK is on :1
DISPLAY=:1 xwd -root 2>/dev/null | head -1 || echo "xwd n/a"
echo done
