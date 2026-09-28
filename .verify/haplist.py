import os, time
for d in [r'D:/uniterm/kaihongos/entry/build/default/outputs/default']:
    for f in os.listdir(d):
        p = os.path.join(d, f)
        if os.path.isfile(p) and f.endswith('.hap'):
            print(time.strftime('%m-%d %H:%M:%S', time.localtime(os.path.getmtime(p))), f)
