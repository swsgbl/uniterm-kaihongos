import subprocess
r = subprocess.run(['hdc','-t','127.0.0.1:15566','shell','hilog','-x'], capture_output=True, timeout=90)
out = r.stdout.decode('utf-8', errors='replace')
keep = [l for l in out.splitlines() if 'uniterm' in l or '20010055' in l]
seen = set()
for l in keep:
    key = l[6:16]
    if 'Ace' in l or 'Sig' in l or 'signal' in l or 'spawn' in l.lower() or 'Crash' in l or 'crash' in l:
        print(l[:180])
