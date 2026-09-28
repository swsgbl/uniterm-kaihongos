import os, time
d = r'D:/uniterm/evidence/M5/relay2'
fs = []
for f in os.listdir(d):
    p = os.path.join(d, f)
    if os.path.isfile(p):
        fs.append((os.path.getmtime(p), f))
fs.sort(reverse=True)
for m, f in fs[:15]:
    print(time.strftime('%m-%d %H:%M:%S', time.localtime(m)), f)
