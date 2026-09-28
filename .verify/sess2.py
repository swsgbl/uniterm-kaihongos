import json, io
# find which session file belongs to the twin agent: look for 'iter8' activity
import glob, os
for p in sorted(glob.glob(os.path.expanduser(r'~/.hmharness/sessions/2026/09/28/*.jsonl')), key=os.path.getmtime, reverse=True)[:4]:
    hit = 0
    first_user = None
    with io.open(p, encoding='utf-8', errors='replace') as fh:
        for line in fh:
            if 'iter8' in line:
                hit += 1
            if first_user is None and '"role":"user"' in line and 'RESUME' not in line:
                try:
                    j = json.loads(line)
                    first_user = str(j)[:120]
                except Exception:
                    pass
    print(os.path.basename(p), 'iter8-hits:', hit)
