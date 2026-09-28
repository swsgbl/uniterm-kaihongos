import json, io, glob, os
p = os.path.expanduser(r'~/.hmharness/sessions/2026/09/28/2026-09-28T00-23-25-4b8m0o.jsonl')
lines = io.open(p, encoding='utf-8', errors='replace').read().splitlines()
print('total lines', len(lines))
# last assistant text
last_texts = []
for line in lines[-60:]:
    try:
        j = json.loads(line)
    except Exception:
        continue
    s = json.dumps(j, ensure_ascii=False)
    if '"type":"assistant"' in s or '"role":"assistant"' in s:
        last_texts.append(s[:500])
for t in last_texts[-4:]:
    print('---')
    print(t)
