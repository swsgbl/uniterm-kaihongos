#!/bin/bash
echo "== uterm bash history (this session) =="
tail -5 /home/uterm/.bash_history 2>/dev/null || echo NO_HISTORY_FILE
stat -c '%y %n' /home/uterm/.bash_history 2>/dev/null
echo DONE
