import os, time
# search whole repo for haps modified after 08:20 today
for root in [r'D:/uniterm']:
    for r, ds, fs in os.walk(root):
        if '.git' in r or 'node_modules' in r or '\\build\\default\\cache' in r:
            ds[:] = []
            continue
        for f in fs:
            if f.endswith('.hap') or f.endswith('.p7b') or 'signed' in f.lower():
                p = os.path.join(r, f)
                m = os.path.getmtime(p)
                if m > time.mktime(time.strptime('2026-09-28 08:15:00', '%Y-%m-%d %H:%M:%S')):
                    print(time.strftime('%m-%d %H:%M:%S', time.localtime(m)), p.replace('D:/uniterm/', ''))
