#!/bin/bash
echo "=== sshd/ports ==="
(ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null) | grep -E ':(2222|5432|6379)\s' || echo "NO 2222/5432/6379 listeners"
echo "=== sshd procs ==="
ps aux | grep -v grep | grep sshd || echo "no sshd proc"
