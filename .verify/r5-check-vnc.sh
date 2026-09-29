#!/usr/bin/env bash
pgrep -af x11vnc
echo ---
(ss -ltn 2>/dev/null || netstat -ltn) | grep -E ':5900'
echo ---
head -40 /tmp/vnc-r5.log 2>/dev/null
echo done
