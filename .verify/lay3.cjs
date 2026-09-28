const fs = require('fs');
const j = fs.readFileSync('D:/uniterm/evidence/M5/relay2/iter3-layout.json', 'utf8');
const m = [...j.matchAll(/"text"\s*:\s*"([^"]{1,80})"/g)].map(x => x[1]);
console.log(m.slice(0, 30).join(' | '));
