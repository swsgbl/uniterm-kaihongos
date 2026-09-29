#!/usr/bin/env bash
env -u WAYLAND_DISPLAY DISPLAY=:1 xmessage -geometry 500x160+300+200 "VNC-PARITY-OK" &
sleep 1
pgrep -af xmessage
echo done
