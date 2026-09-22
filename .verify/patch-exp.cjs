const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
// WantParams getter
let wp = fs.readFileSync('D:/uniterm/kaihongos/entry/src/main/ets/common/WantParams.ets', 'utf8');
if (!wp.includes('getExportPass')) {
  const a = `  static getImportEncPass(): string {`;
  const b = `  /** M3 relay-2 dev channel: --ps exportPass <p> (empty = plaintext). */
  static getExportPass(): string {
    const w = WantParams.want;
    if (w === null || w.parameters === undefined || w.parameters === null) {
      return '';
    }
    const v = w.parameters['exportPass'];
    if (typeof v === 'string') {
      return v;
    }
    return '';
  }

  static getImportEncPass(): string {`;
  if (!wp.includes(a)) { console.error('WP MISS'); process.exit(1); }
  wp = wp.replace(a, b);
  fs.writeFileSync('D:/uniterm/kaihongos/entry/src/main/ets/common/WantParams.ets', wp);
  console.log('WP OK');
}
// ConnList: consume exportPass in aboutToAppear (after load fold-in so conns exist)
const c = `      const fails = await this.store.revealSecrets();
      if (fails > 0) {
        this.showToast('\u6709 ' + fails + ' \u4e2a\u51ed\u636e\u5b57\u6bb5\u65e0\u6cd5\u89e3\u5bc6(\u4e3b\u5bc6\u7801\u672a\u89e3\u9501\u6216\u9519\u8bef)');
      }`;
const d = `      const fails = await this.store.revealSecrets();
      if (fails > 0) {
        this.showToast('\u6709 ' + fails + ' \u4e2a\u51ed\u636e\u5b57\u6bb5\u65e0\u6cd5\u89e3\u5bc6(\u4e3b\u5bc6\u7801\u672a\u89e3\u9501\u6216\u9519\u8bef)');
      }
      // M3 relay-2 dev channel: auto-export once data is folded in.
      const expPass0 = WantParams.getExportPass();
      if (expPass0 !== null && expPass0.length >= 0) {
        const hasExp = WantParams.wantHas('exportPass');
        if (hasExp) {
          WantParams.setWant({} as Want);
          this.exportPassword = expPass0;
          this.doExport();
        }
      }`;
if (!t.includes(c)) { console.error('C MISS'); process.exit(1); }
t = t.replace(c, d);
fs.writeFileSync(path, t);
console.log('CL OK');
