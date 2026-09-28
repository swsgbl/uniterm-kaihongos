import os
for root, ds, fs in os.walk(r'D:/uniterm/evidence/M4'):
    for f in fs:
        if f.endswith('.cjs') or 'e2e' in f.lower() or 'vt220' in f.lower():
            print(os.path.join(root, f).replace('D:/uniterm/evidence/', ''))
