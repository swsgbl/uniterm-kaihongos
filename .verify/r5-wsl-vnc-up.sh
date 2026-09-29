#!/usr/bin/env bash
pkill -f 'x11vnc -display :1' 2>/dev/null; sleep 1
# Kill stray xclock
pkill -f 'xclock' 2>/dev/null
if ! pgrep -f 'x11vnc' >/dev/null; then
  env -u WAYLAND_DISPLAY -u DISPLAY DISPLAY=:1 XAUTHORITY= x11vnc \
    -display :1 -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900 \
    >/tmp/vnc-r5.log 2>&1 &
fi
sleep 2
pgrep -af x11vnc
echo ---
(ss -ltn 2>/dev/null || netstat -ltn) | grep -E ':5900'
echo ---
tail -25 /tmp/vnc-r5.log 2>/dev/null
echo done
