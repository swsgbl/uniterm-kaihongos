import json, os
cfg = os.path.expanduser(r'~/.hmharness/config.json')
j = json.load(open(cfg, encoding='utf-8'))
print(list(j.keys()))
for k in j:
    v = j[k]
    print(k, '=', str(v)[:200])
