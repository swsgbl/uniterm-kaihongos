import subprocess
r = subprocess.run(['hdc','-t','127.0.0.1:15566','shell','hilog','-x'], capture_output=True, timeout=90)
out = r.stdout.decode('utf-8', errors='replace')
keep = [l for l in out.splitlines() if 'uniterm' in l]
# find appspawn / AceForwardCompatibility lines = launch attempts; and DfxSignalHandler = crash
for l in keep:
    if any(k in l for k in ['AceForwardCompatibility', 'DfxSignalHandler', 'APPSPAWN', 'appspawn', 'exit with signal']):
        print(l[:170])
