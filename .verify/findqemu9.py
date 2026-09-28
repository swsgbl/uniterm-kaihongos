import glob, os
roots = [r'C:/Users/hongfu/AppData/Roaming/npm/node_modules/@hmharness', r'G:/hmharness']
for root in roots:
    if not os.path.exists(root):
        continue
    for dirpath, ds, fs in os.walk(root):
        if 'node_modules' in dirpath and dirpath.count(os.sep) > 6:
            ds[:] = []
            continue
        for f in fs:
            if f.endswith(('.js', '.mjs', '.cjs', '.json', '.md')):
                p = os.path.join(dirpath, f)
                try:
                    data = open(p, encoding='utf-8', errors='replace').read()
                except Exception:
                    continue
                if 'QEMU_DIR' in data and 'launch_qemu_vnc' in data:
                    i = data.find('QEMU_DIR')
                    print('FILE:', p)
                    print(data[max(0, i-500):i+500].replace('\n', ' | ')[:900])
                    raise SystemExit
