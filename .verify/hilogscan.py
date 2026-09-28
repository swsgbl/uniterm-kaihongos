import subprocess, time
# what got installed at 08:26-08:27: replay is impossible; instead find the LAST successful launch of uniterm (EntryAbility foreground, no crash) to identify which hap was on device before the bad install.
r = subprocess.run(['hdc','-t','127.0.0.1:15566','shell','hilog','-x'], capture_output=True, timeout=90)
out = r.stdout.decode('utf-8', errors='replace')
keep = [l for l in out.splitlines() if 'uniterm' in l]
print('total uniterm lines:', len(keep))
# crashes by hour
from collections import Counter
c = Counter()
for l in keep:
    if 'SIGABRT' in l or 'cppcrash' in l.lower() or 'DfxSignalHandler' in l:
        c[l[6:13]] += 1
for k in sorted(c):
    print('crash-ish', k, c[k])
# first & last line timestamp
print('first:', keep[0][:60] if keep else None)
print('last:', keep[-1][:60] if keep else None)
