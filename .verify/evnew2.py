import os, time
d = r'D:/uniterm/evidence/M5/relay2'
fs = []
for f in os.listdir(d):
    p = os.path.join(d, f)
    if os.path.isfile(p) and (f.startswith('iter8') or f.startswith('_') or 'REPORT' in f.upper()):
        fs.append((os.path.getmtime(p), f))
fs.sort(reverse=True)
for m, f in fs[:20]:
    print(time.strftime('%m-%d %H:%M:%S', time.localtime(m)), f)
print('---REPORT files anywhere in M5---')
for root, ds, files in os.walk(r'D:/uniterm/evidence/M5'):
    for f in files:
        if 'REPORT' in f.upper():
            p = os.path.join(root, f)
            print(time.strftime('%m-%d %H:%M', time.localtime(os.path.getmtime(p))), p.replace('D:/uniterm/evidence/', ''))
