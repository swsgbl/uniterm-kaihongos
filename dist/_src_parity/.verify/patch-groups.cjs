const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
let ok = 0;
function rep(a, b, n) {
  if (t.includes(a)) { t = t.split(a).join(b); ok++; console.log(n, 'OK'); }
  else console.error(n, 'MISS');
}
rep('    this.encImportPromise = encImport;',
    '    this.encImportPromise = encImport;\n    this.encImportGroups = [];', 'A');
rep('if (encRes !== null) {\n          this.pendingImport',
    'if (encRes !== null) {\n          this.encImportGroups = encRes.groups;\n          this.pendingImport', 'B');
rep('      if (this.pendingImport.length > 0) {\n        for (let pi = 0; pi < this.pendingImport.length; pi++) {',
    '      if (this.encImportGroups.length > 0) {\n        for (let gi = 0; gi < this.encImportGroups.length; gi++) {\n          this.store.groups.push(this.encImportGroups[gi]);\n        }\n        hilog.info(IDOMAIN, ITAG, \'want enc groups pushed=%{public}d\', this.encImportGroups.length);\n      }\n      if (this.pendingImport.length > 0) {\n        for (let pi = 0; pi < this.pendingImport.length; pi++) {', 'C');
rep('  private encImportPromise: Promise<ImportResult | null> = Promise.resolve(null);',
    '  private encImportPromise: Promise<ImportResult | null> = Promise.resolve(null);\n  private encImportGroups: GroupRec[] = [];', 'D');
fs.writeFileSync(path, t);
console.log('done', ok);
