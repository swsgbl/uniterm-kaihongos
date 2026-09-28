const fs = require('fs');
const p = 'D:\\uniterm\\kaihongos\\entry\\src\\main\\ets\\pages\\SftpPanel.ets';
const c = fs.readFileSync(p, 'utf8');
const idx = c.indexOf('connIdIn');
console.log('snippet:', JSON.stringify(c.slice(idx - 40, idx + 40)));
const lines = c.split('\n');
lines.forEach((l, i) => { if (l.includes('connIdIn')) console.log(i + 1, JSON.stringify(l)); });
