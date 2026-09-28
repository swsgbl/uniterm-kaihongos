const fs = require('fs');
const path = require('path');
const root = process.argv[2];
// find full qemu-system command line from any session: look for run_command invocations that START qemu
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
const seen = new Set();
for (const p of walk(root).sort((a, b) => fs.statSync(a).mtimeMs - fs.statSync(b).mtimeMs)) {
  const data = fs.readFileSync(p, 'utf8');
  if (!data.includes('qemu-system-x86_64')) continue;
  const lines = data.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
    if (o.t !== 'assistant' || !o.tool_calls) continue;
    for (const c of o.tool_calls) {
      if (c.function && c.function.name === 'run_command') {
        let arg;
        try { arg = JSON.parse(c.function.arguments); } catch (e) { continue; }
        const cmd = String(arg.command || '');
        if (!cmd.includes('qemu-system-x86_64')) continue;
        const key = cmd.slice(0, 150);
        if (seen.has(key)) continue;
        seen.add(key);
        console.log('=== ' + path.basename(p) + ' L' + i);
        console.log(cmd.slice(0, 1500));
        console.log('');
      }
    }
  }
}
console.log('TOTAL unique:', seen.size);
