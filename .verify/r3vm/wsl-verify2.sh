#!/bin/bash
echo "== auth.log uterm =="
grep -iE 'Accepted|session opened|uterm' /var/log/auth.log 2>/dev/null | tail -12 || journalctl -u ssh --since "30 min ago" --no-pager 2>/dev/null | grep -iE 'Accepted|uterm' | tail -12 || echo NO_AUTHLOG
echo "== who =="
who | tail -5
echo DONE
