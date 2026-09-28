import json, io, os
p = os.path.expanduser(r'~/.hmharness/sessions/2026/09/28/2026-09-28T00-23-25-4b8m0o.jsonl')
lines = io.open(p, encoding='utf-8', errors='replace').read().splitlines()
# print structure of last 10 entries
for line in lines[-10:]:
    try:
        j = json.loads(line)
        keys = list(j.keys())
        typ = j.get('type') or j.get('role') or ''
        msg = j.get('message') or {}
        role = msg.get('role', '') if isinstance(msg, dict) else ''
        content = msg.get('content') if isinstance(msg, dict) else None
        txt = ''
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get('type') == 'text':
                    txt += c.get('text', '')[:200]
        elif isinstance(content, str):
            txt = content[:200]
        print(typ or role, '|', keys[:6], '|', txt[:200].replace('\n', ' '))
    except Exception as e:
        print('ERR', str(e)[:60], line[:100])
