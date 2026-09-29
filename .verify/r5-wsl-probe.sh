#!/usr/bin/env bash
# M5 relay5 WSL target probe
set +e
echo "=== hosts/sshd ==="
pgrep -a sshd | head -5
echo "=== Xvfb ==="
pgrep -a Xvfb | head -5
echo "=== x11vnc (5900) ==="
pgrep -a x11vnc | head -5
ss -ltnp 2>/dev/null | grep -E ':5900|:3389|:2323|:2222|:5432|:6379' || netstat -ltnp 2>/dev/null | grep -E ':5900|:3389|:2323|:2222|:5432|:6379'
echo "=== xrdp ==="
pgrep -a xrdp | head -5
service xrdp status 2>&1 | head -3
echo "=== telnetd / inetd ==="
pgrep -a telnetd | head -5
pgrep -a inetd | head -5
which xmessage xterm x11vnc xrdp telnetd 2>&1
echo "=== uterm user ==="
id uterm 2>&1
echo "=== display :1 content check ==="
DISPLAY=:1 xmessage -query "VNC-PARITY-OK?" 2>&1 | head -2
echo "=== sshd port ==="
(ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -E ':(2222|5900|3389|2323)' 
echo "=== probe done ==="
