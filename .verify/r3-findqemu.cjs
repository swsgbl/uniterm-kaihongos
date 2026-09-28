const fs = require('fs');
const path = require('path');
// walk sessions dir recursively, find files containing qemu-system-x86_64 with a real path
const root = process.argv[2];
const pat = /qemu-system-x86_64[^\n"]{0,400}/gi;
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
const hits = [];
for (const p of walk(root)) {
  let data;
  try { data = fs.readFileSync(p, 'utf8'); } catch (e) { continue; }
  if (data.includes('qemu-system-x86_64')) hits.push(p);
}
hits.sort((a, b) => fs.statSync(a).mtimeMs - fs.statSync(b).mtimeMs);
console.log('files with qemu-system-x86_64:', hits.length);
for (const p of hits) console.log(fs.statSync(p).mtime.toISOString(), p);
