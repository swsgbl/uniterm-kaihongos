const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
const a = '      if (this.pendingImport.length > 0) {\r\n        for (let pi = 0; pi < this.pendingImport.length; pi++) {\r\n          this.store.upsertConn(this.pendingImport[pi]);';
const b = '      if (this.encImportGroups.length > 0) {\r\n        for (let gi = 0; gi < this.encImportGroups.length; gi++) {\r\n          this.store.groups.push(this.encImportGroups[gi]);\r\n        }\r\n        hilog.info(IDOMAIN, ITAG, \'want enc groups pushed=%{public}d\', this.encImportGroups.length);\r\n      }\r\n      if (this.pendingImport.length > 0) {\r\n        for (let pi = 0; pi < this.pendingImport.length; pi++) {\r\n          this.store.upsertConn(this.pendingImport[pi]);';
if (!t.includes(a)) { console.error('C NOT FOUND'); process.exit(1); }
t = t.replace(a, b);
fs.writeFileSync(path, t);
console.log('PATCHED C');
