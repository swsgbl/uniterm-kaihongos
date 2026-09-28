import os, re
# check hmharness source for QEMU_DIR resolution
p = None
import glob
for cand in glob.glob(r'C:/Users/hongfu/AppData/Roaming/npm/node_modules/@hmharness/cli/dist/*.mjs') + glob.glob(r'C:/Users/hongfu/AppData/Roaming/npm/node_modules/@hmharness/cli/dist/*.js'):
    data = open(cand, encoding='utf-8', errors='replace').read()
    if 'QEMU_DIR' in data:
        i = data.find('QEMU_DIR')
        print(cand)
        print(data[max(0,i-400):i+400])
        break
