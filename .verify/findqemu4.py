import glob, os, io
found = set()
for p in sorted(glob.glob(os.path.expanduser(r'~/.hmharness/sessions/2026/09/*.jsonl')), key=os.path.getmtime, reverse=True)[:80]:
    try:
        data = io.open(p, encoding='utf-8', errors='replace').read()
    except Exception:
        continue
    if 'kaihong' not in data.lower():
        continue
    for line in data.splitlines():
        low = line.lower()
        if ('qemu-system' in low or 'launch_qemu' in low) and 'dir' not in low[:20]:
            # extract any path-like token containing kaihong
            import re
            for m in re.finditer(r'[A-Z]:\\\\[^"\\s]*[Kk]aihong[^"\\s]*', line):
                found.add(m.group().replace('\\\\', '\\'))
            for m in re.finditer(r'[A-Z]:/[^"\s]*[Kk]aihong[^"\s]*', line):
                found.add(m.group())
for f in sorted(found)[:20]:
    print(f)
