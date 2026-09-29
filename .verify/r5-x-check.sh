#!/usr/bin/env bash
echo "env check:"
env | grep -iE 'display|wayland|dbus|xauth'
echo ---
ls -la /tmp/.X11-unix/ 2>/dev/null
echo ---
# Xvfb :1 socket
echo "try connecting to :1 with a plain X client (xclock -b):"
DISPLAY=:1 xclock -geometry 200x100+50+50 & 
sleep 1
pgrep -af xclock
echo ---
# Check if x11vnc can be told to use -xdisplay directly
echo "man check: does x11vnc honor XAUTHORITY env?"
grep -riE 'wayland' /usr/share/doc/x11vnc/ 2>/dev/null | head -5
done
exit 0
