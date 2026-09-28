import json, os
cfg = os.path.expanduser(r'~/.hmharness/config.json')
j = json.load(open(cfg, encoding='utf-8'))
print(json.dumps(j.get('vm', {}), ensure_ascii=False, indent=1))
