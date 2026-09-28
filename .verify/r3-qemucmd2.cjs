const fs = require('fs');
const f = process.argv[2];
const data = fs.readFileSync(f, 'utf8');
const lines = data.split(/\r?\n/);
const seen = new Set();
for (let i = 0; i < lines.length; i++) {
  let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
  let txt = '';
  if (o.t === 'tool') txt = String(o.output || '');
  else if (o.t === 'assistant') txt = (o.text || '') + JSON.stringify(o.tool_calls || []);
  else if (o.t === 'user') { const c = o.message ? o.message.content : o.content; txt = typeof c === 'string' ? c : JSON.stringify(c); }
  txt = String(txt || '');
  if (!txt.toLowerCase().includes('qemu-system')) continue;
  // double-unescape (JSON-in-JSON)
  let un = txt.replace(/\\\\/g, '\x01').replace(/\\"/g, '"').replace(/\\n/g, '\n').replace(/\x01/g, '\\');
  const idx = un.toLowerCase().indexOf('qemu-system');
  // walk back to find start of the command (drive letter)
  let start = Math.max(0, idx - 400);
  const seg = un.slice(start, idx + 600);
  const key = seg.slice(0, 120);
  if (seen.has(key)) continue;
  seen.add(key);
  console.log('=== L' + i + ' [' + o.t + ']');
  console.log(seg.replace(/\s+/g, ' ').slice(0, 700));
  console.log('');
}
