import subprocess
# search past sessions for the launch command used for the KaihongOS QEMU
import glob, os, io
pats = []
for p in sorted(glob.glob(os.path.expanduser(r'~/.hmharness/sessions/2026/09/2[6-8]/*.jsonl')), key=os.path.getmtime, reverse=True)[:30]:
    try:
        data = io.open(p, encoding='utf-8', errors='replace').read()
    except Exception:
        continue
    if 'launch_qemu' in data or 'kaihong-serial' in data:
        for line in data.splitlines():
            if 'launch_qemu' in line and ('cmd' in line.lower() or 'start' in line.lower() or '.cmd' in line):
                i = line.find('launch_qemu')
                print(os.path.basename(p), '>>', line[max(0, i-180):i+80].replace('\\n', ' ')[:260])
                break
