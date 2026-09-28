import os
# The dist file uses 'QEMU_DIR' placeholder likely replaced at runtime from HMH env. Search hmharness home for the actual KaihongOS dir
for root in [r'C:/Users/hongfu/.hmharness']:
    for dirpath, ds, fs in os.walk(root):
        if 'sessions' in dirpath or 'skills' in dirpath:
            ds[:] = []
            continue
        for f in fs:
            if 'qemu' in f.lower() or 'kaihong' in f.lower():
                print(os.path.join(dirpath, f))
# also look for env file
for cand in [r'C:/Users/hongfu/.hmharness/env.json', r'C:/Users/hongfu/.hmharness/env']:
    if os.path.exists(cand):
        print('EXISTS', cand)
