const fs = require('fs');
const j = fs.readFileSync('D:/uniterm/evidence/M5/relay2/iter1-layout-store.json', 'utf8');
const m = [...j.matchAll(/"text"\s*:\s*"([^"]{1,80})"/g)].map(x => x[1]);
console.log('texts:', [...new Set(m)].slice(0, 40).join(' | '));
