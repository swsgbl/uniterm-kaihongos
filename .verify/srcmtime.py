import os, time
roots = [r'D:/uniterm/kaihongos/entry/src/main/ets', r'D:/uniterm/kaihongos/AppScope', r'D:/uniterm/kaihongos/entry/src/main/resources']
files = []
for root in roots:
    for r, d, fs in os.walk(root):
        for f in fs:
            p = os.path.join(r, f)
            files.append((os.path.getmtime(p), p))
files.sort(reverse=True)
for m, p in files[:12]:
    print(time.strftime('%m-%d %H:%M:%S', time.localtime(m)), p.replace('D:/uniterm/', ''))
