const fs = require('fs');
// search session logs for qemu launch command
const dir = process.argv[2];
const pat = new RegExp(process.argv[3], 'i');
const maxLen = parseInt(process.argv[4] || '400', 10);
const files = fs.readdirSync(dir).filter(f => f.endsWith('.jsonl'));
for (const f of files) {
  const lines = fs.readFileSync(dir + '/' + f, 'utf8').split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
    let txt = '';
    if (o.t === 'assistant') { txt = (o.text || '') + ' ' + JSON.stringify(o.tool_calls || ''); }
    else if (o.t === 'tool') { txt = String(o.output || ''); }
    else if (o.t === 'user') { txt = typeof (o.message ? o.message.content : o.content) === 'string' ? (o.message ? o.message.content : o.content) : JSON.stringify(o.message ? o.message.content : o.content); }
    if (pat.test(txt)) {
      const m = txt.match(pat);
      const idx = txt.toLowerCase().indexOf(m[0].toLowerCase());
      console.log('=== ' + f + ' L' + i + ' [' + o.t + ']');
      console.log(txt.slice(Math.max(0, idx - 100), idx + maxLen).replace(/\\n/g, '\n'));
      console.log('');
    }
  }
}
