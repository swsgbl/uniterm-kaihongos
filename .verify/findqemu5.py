import glob, os, io, re
found = set()
for p in sorted(glob.glob(os.path.expanduser(r'~/.hmharness/sessions/2026/09/*.jsonl')), key=os.path.getmtime, reverse=True)[:100]:
    try:
        data = io.open(p, encoding='utf-8', errors='replace').read()
    except Exception:
        continue
    if '15566' not in data:
        continue
    for m in re.finditer(r'[A-Za-z]:[/\\]{1,2}[^\s"\'<>|]{2,80}(?:aihong|AIHONG)[^\s"\'<>|]{0,60}', data):
        found.add(m.group())
for f in sorted(found)[:30]:
    print(f)
