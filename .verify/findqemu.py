import os, glob
cands = glob.glob(r'D:/uniterm/**/launch_qemu_vnc.cmd', recursive=True)
print(cands[:5])
# also try the .hmharness config for QEMU_DIR
import json
cfg = os.path.expanduser(r'~/.hmharness/config.json')
if os.path.exists(cfg):
    j = json.load(open(cfg, encoding='utf-8'))
    for k in j:
        if 'qemu' in k.lower() or 'kaihong' in k.lower():
            print(k, '=', j[k] if not isinstance(j[k], dict) else list(j[k].keys()))
