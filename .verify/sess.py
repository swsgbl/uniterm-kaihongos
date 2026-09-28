import subprocess
# check session logs to understand the twin agent: which prompt, what it's doing. Look at the most recent session files
import os, glob, time
d = os.path.expanduser(r'~/.hmharness/sessions/2026/09/28')
if os.path.exists(d):
    fs = sorted(glob.glob(d + '/*.jsonl'), key=os.path.getmtime, reverse=True)
    for p in fs[:6]:
        print(time.strftime('%H:%M:%S', time.localtime(os.path.getmtime(p))), os.path.getsize(p), os.path.basename(p))
