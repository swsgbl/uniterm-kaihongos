const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
const a = `      // M3 relay-2 dev channel: auto-export once data is folded in.
      const expPass0 = WantParams.getExportPass();
      if (expPass0 !== null && expPass0.length >= 0) {
        const hasExp = WantParams.wantHas('exportPass');
        if (hasExp) {
          WantParams.setWant({} as Want);
          this.exportPassword = expPass0;
          this.doExport();
        }
      }`;
const b = `      // M3 relay-2 dev channel: auto-export once data is folded in
      // (exportPass="-" means plaintext; any other value is the password).
      const expPass0 = WantParams.getExportPass();
      if (expPass0 === '-') {
        WantParams.setWant({} as Want);
        this.exportPassword = '';
        this.doExport();
      } else if (expPass0.length > 0) {
        WantParams.setWant({} as Want);
        this.exportPassword = expPass0;
        this.doExport();
      }`;
if (!t.includes(a)) { console.error('A MISS'); process.exit(1); }
t = t.replace(a, b);
fs.writeFileSync(path, t);
console.log('OK');
