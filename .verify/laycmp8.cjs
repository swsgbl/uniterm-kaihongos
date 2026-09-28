// structural compare: iter8b layout (cur-layout3.json) vs iter7 layout (iter7-layout.json)
// count nodes by type, list top-level structure, text inventory
const fs = require('fs');
function load(f) {
  const j = JSON.parse(fs.readFileSync(f, 'utf8'));
  const stats = { total: 0, byType: {}, texts: [] };
  (function w(n, d) {
    if (!n) return;
    stats.total++;
    const a = n.attributes || {};
    const t = a.type || '?';
    stats.byType[t] = (stats.byType[t] || 0) + 1;
    if (t === 'Text' && a.text) stats.texts.push(String(a.text).slice(0, 30));
    (n.children || []).forEach(c => w(c, d + 1));
  })(j, 0);
  return stats;
}
const files = {
  iter8b: 'D:/uniterm/evidence/M5/relay2/cur-layout3.json',
  iter7: 'D:/uniterm/evidence/M5/relay2/iter7-layout.json',
};
for (const [k, f] of Object.entries(files)) {
  try {
    const s = load(f);
    console.log('==', k, 'total:', s.total, 'texts:', s.texts.length);
    console.log('   byType:', JSON.stringify(s.byType));
    console.log('   texts:', s.texts.slice(0, 40).join(' | '));
  } catch (e) { console.log('==', k, 'LOAD-ERR', e.message.slice(0, 100)); }
}
