const fs = require('fs');
const j = fs.readFileSync('D:/uniterm/evidence/M5/relay2/iter1-layout.json', 'utf8');
console.log('len=', j.length);
const m = [...j.matchAll(/"text"\s*:\s*"([^"]{1,80})"/g)].map(x => x[1]);
console.log('text nodes:', m.length);
console.log([...new Set(m)].slice(0, 60).join(' | '));
// check what ability is foreground
const attrs = [...j.matchAll(/"attributes".{0,400}/g)].slice(0, 3);
for (const a of attrs) console.log(a[0].substring(0, 200));
