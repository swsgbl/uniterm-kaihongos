const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
const i = t.indexOf('pendingImport.length > 0');
console.log(JSON.stringify(t.substring(i - 300, i + 500)));
