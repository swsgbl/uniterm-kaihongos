// walk cur-layout.json: list Text nodes + window/page info
const fs = require('fs');
const f = 'D:/uniterm/evidence/M5/relay2/cur-layout.json';
const j = JSON.parse(fs.readFileSync(f, 'utf8'));
let texts = [];
function walk(n, d) {
  if (!n) return;
  const a = n.attributes || {};
  if (a.type === 'Text' && a.text) texts.push({ d, text: String(a.text).slice(0, 50) });
  if (a.type === 'Window' || a.type === 'Page') texts.push({ d, text: '[' + a.type + '] ' + (a.bundle || '') });
  (n.children || []).forEach(c => walk(c, d + 1));
}
walk(j, 0);
console.log('TOTAL TEXT NODES:', texts.length);
for (const t of texts.slice(0, 60)) console.log(String(t.d).padStart(2, '0'), t.text);
