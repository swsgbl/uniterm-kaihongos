const fs = require('fs');
// extract qemu-system command lines with real paths from a session file
const f = process.argv[2];
const data = fs.readFileSync(f, 'utf8');
const lines = data.split(/\r?\n/);
const seen = new Set();
for (let i = 0; i < lines.length; i++) {
  let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
  let txt = '';
  if (o.t === 'tool' ) txt = String(o.output || '');
  else if (o.t === 'assistant') txt = (o.text || '') + JSON.stringify(o.tool_calls || []);
  else if (o.t === 'user') { const c = o.message ? o.message.content : o.content; txt = typeof c === 'string' ? c : JSON.stringify(c); }
  txt = String(txt || '');
  if (!txt.includes('qemu-system-x86_64')) continue;
  // unescape JSON string escapes
  const un = txt.replace(/\\\\/g, '\\').replace(/\\"/g, '"').replace(/\\n/g, '\n');
  const re = /[A-Za-z]:[^\s"]*qemu-system-x86_64[^\s"]*(.exe)?/gi;
  let m;
  const local = [];
  while ((m = re.exec(un))) { if (!local.includes(m[0])) local.push(m[0]); }
  for (const p of local) {
    const key = p + ' ||| ' + f;
    if (seen.has(p)) continue;
    seen.add(p);
    console.log('L' + i, '[' + o.t + ']', p);
  }
}
