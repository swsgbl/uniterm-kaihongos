// M6 relay2: rebrand hilog tags uniterm.* -> oat.* + bundle refs + AI prompt
const fs = require('fs');
const path = require('path');
const ROOT = 'D:/uniterm/kaihongos/entry/src/main/ets';
const files = [];
(function walk(d){ for (const e of fs.readdirSync(d,{withFileTypes:true})) {
  if (e.isDirectory()) walk(path.join(d,e.name)); else if (e.name.endsWith('.ets')) files.push(path.join(d,e.name));
}})(ROOT);
let total = 0;
for (const f of files) {
  let s = fs.readFileSync(f,'utf8');
  const before = s;
  // hilog tags (runtime visible)
  s = s.replace(/'uniterm\.([a-z0-9]+)'/g, "'oat.$1'");
  // bundle name refs in comments
  s = s.replace(/net\.uniterm\.poc/g, 'com.oneaiterm.terminal');
  fs.writeFileSync(f,s);
  const n = (before.match(/uniterm\.[a-z0-9]+|net\.uniterm\.poc/g)||[]).length - (s.match(/uniterm\.[a-z0-9]+|net\.uniterm\.poc/g)||[]).length;
  if (n>0) { console.log(path.basename(f), 'replaced', n); total += n; }
}
console.log('TOTAL', total);
