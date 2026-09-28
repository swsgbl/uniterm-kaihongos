import subprocess
r = subprocess.run(['hdc','-t','127.0.0.1:15566','shell','hilog','-x'], capture_output=True, timeout=90)
out = r.stdout.decode('utf-8', errors='replace')
lines = out.splitlines()
# all install events today for our bundle
inst = [l for l in lines if 'net.uniterm.poc' in l and ('Installer' in l or 'install' in l.lower())]
print('install-ish lines:', len(inst))
for l in inst[-12:]:
    print(l[:170])
