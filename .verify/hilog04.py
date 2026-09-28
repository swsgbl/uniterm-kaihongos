import subprocess
r = subprocess.run(['hdc','-t','127.0.0.1:15566','shell','hilog','-x'], capture_output=True, timeout=90)
out = r.stdout.decode('utf-8', errors='replace')
lines = [l for l in out.splitlines() if 'uniterm' in l and '09-28 04:' in l]
print('hits', len(lines))
for l in lines[:14]:
    print(l[:170])
