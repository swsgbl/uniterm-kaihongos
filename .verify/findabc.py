import os
d = r'D:/uniterm/kaihongos/entry/build/default'
for r, ds, fs in os.walk(d):
    for f in fs:
        if f.endswith('.abc') or f.endswith('.har') or f == 'pack.info':
            p = os.path.join(r, f)
            print(os.path.getsize(p), p.replace('D:/uniterm/kaihongos/entry/build/', '...'))
