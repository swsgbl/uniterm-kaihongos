#!/bin/bash
echo "== port 2222 =="
ss -tln | grep -E ':2222|:22 ' || echo NO_2222
echo "== sshd proc =="
ps aux | grep -v grep | grep sshd || echo NO_SSHD
echo "== test from inside =="
echo | timeout 3 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/2222' 2>/dev/null && echo TCPPASS || echo TCPFAIL
echo DONE
