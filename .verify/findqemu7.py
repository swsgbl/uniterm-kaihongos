import glob, os, io, re
# brute: any session containing 'QEMU_DIR' resolved value or qemu-system-x86_64 command with kaihong
for p in sorted(glob.glob(os.path.expanduser(r'~/.hmharness/sessions/2026/09/*.jsonl')), key=os.path.getmtime, reverse=True)[:150]:
    try:
        data = io.open(p, encoding='utf-8', errors='replace').read()
    except Exception:
        continue
    if 'qemu-system-x86_64' not in data:
        continue
    for line in data.splitlines():
        if 'qemu-system-x86_64' in line:
            i = line.find('qemu-system-x86_64')
            seg = line[max(0, i-300):i+200]
            m = re.search(r'[A-Za-z]:[/\\]{1,2}[^\s"\'<>|]{2,100}', seg[::-1][::-1])
            # print cwd-ish fragments
            print(os.path.basename(p), '|', seg.replace('\\n', ' ')[-280:])
            break
    else:
        continue
    break
