import json, io, os
p = os.path.expanduser(r'~/.hmharness/sessions/2026/09/28/2026-09-28T00-23-25-4b8m0o.jsonl')
lines = io.open(p, encoding='utf-8', errors='replace').read().splitlines()
# entries have 't' type field: print last 12 with text/tool name/output snippet
for line in lines[-14:]:
    try:
        j = json.loads(line)
    except Exception:
        continue
    t = j.get('t')
    if t == 'text':
        print('[TEXT]', str(j.get('text', ''))[:260].replace('\n', ' '))
    elif 'tool' in j:
        print('[CALL]', j.get('tool'), str(j.get('granted'))[:60].replace('\n', ' '))
    elif 'name' in j:
        print('[RESULT]', j.get('name'), str(j.get('output', ''))[:160].replace('\n', ' '))
    else:
        print('[?]', t, str(j)[:120])
