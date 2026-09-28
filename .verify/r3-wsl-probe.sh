#!/bin/bash
# probe quickemu config on WSL
echo "=== home ==="; ls ~ | head -30
echo "=== which ==="; which quickemu quickget qemu-system-x86_64 2>/dev/null
echo "=== find kaihong conf ==="
find ~ /opt /srv -maxdepth 4 -iname "*kaihong*" 2>/dev/null | head -20
echo "=== running qemu procs ==="
ps aux | grep -i qemu | grep -v grep
