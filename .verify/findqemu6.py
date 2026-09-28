import glob, os, io, re
# any mention of 15566 with 'start' in older sessions (when VM was started successfully)
hits = []
for p in sorted(glob.glob(os.path.expanduser(r'~/.hmharness/sessions/2026/09/*.jsonl')), key=os.path.getmtime, reverse=True)[:120]:
    try:
        data = io.open(p, encoding='utf-8', errors='replace').read()
    except Exception:
        continue
    if '15566' in data and 'QEMU' in data:
        for line in data.splitlines():
            if '15566' in line and ('vm_qemu' in line and 'start' in line):
                hits.append((os.path.basename(p), line[:200]))
for h in hits[:5]:
    print(h[0], '::', h[1])
