const fs = require('fs');
const path = require('path');
const root = process.argv[2];
const needle = process.argv[3];
function walk(d) {
  let out = [];
  for (const f of fs.readdirSync(d)) {
    const p = path.join(d, f);
    const st = fs.statSync(p);
    if (st.isDirectory()) out = out.concat(walk(p));
    else if (f.endsWith('.jsonl')) out.push(p);
  }
  return out;
}
for (const p of walk(root).sort((a, b) => fs.statSync(a).mtimeMs - fs.statSync(b).mtimeMs)) {
  const data = fs.readFileSync(p, 'utf8');
  if (!data.includes(needle)) continue;
  const lines = data.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
    if (o.t !== 'assistant' || !o.tool_calls) continue;
    for (const c of o.tool_calls) {
      if (c.function && (c.function.name === 'write_file' || c.function.name === 'edit_file')) {
        let arg; try { arg = JSON.parse(c.function.arguments); } catch (e) { continue; }
        const content = String(arg.content || arg.new_string || '');
        if (content.includes(needle)) {
          console.log('=== ' + path.basename(p) + ' L' + i + ' -> ' + arg.path);
          console.log(content.slice(0, 2000));
          console.log('');
        }
      }
    }
  }
}
