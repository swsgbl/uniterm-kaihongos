#!/bin/bash
echo "== last uterm =="
last -n 8 uterm 2>/dev/null || echo no-last
echo "== uterm processes =="
ps aux | grep -v grep | grep -E 'sshd: uterm|postLogin' || echo NO_SESSION
echo DONE
