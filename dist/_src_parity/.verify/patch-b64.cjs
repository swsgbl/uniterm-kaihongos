const fs = require('fs');
const path = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/ConnList.ets';
let t = fs.readFileSync(path, 'utf8');
// import util at top (next to existing imports)
if (!t.includes("import { util } from '@kit.ArkTS';")) {
  const imp = "import { hilog } from '@kit.PerformanceAnalysisKit';";
  if (!t.includes(imp)) { console.error('IMP MISS'); process.exit(1); }
  t = t.replace(imp, imp + "\nimport { util } from '@kit.ArkTS';");
}
const a = `      this.exportDialog = false;
      this.showToast('\u5df2\u5bfc\u51fa ' + conns.length + ' \u4e3b\u673a -> ' + dest +
        (this.exportPassword.length > 0 ? ' (\u52a0\u5bc6)' : ' (\u660e\u6587)'));
      hilog.info(IDOMAIN, ITAG, 'exported conns=%{public}d enc=%{public}d bytes=%{public}d path=%{public}s',
        conns.length, this.exportPassword.length > 0 ? 1 : 0, json.length, dest);`;
const b = `      this.exportDialog = false;
      this.showToast('\u5df2\u5bfc\u51fa ' + conns.length + ' \u4e3b\u673a -> ' + dest +
        (this.exportPassword.length > 0 ? ' (\u52a0\u5bc6)' : ' (\u660e\u6587)'));
      hilog.info(IDOMAIN, ITAG, 'exported conns=%{public}d enc=%{public}d bytes=%{public}d path=%{public}s',
        conns.length, this.exportPassword.length > 0 ? 1 : 0, json.length, dest);
      // relay-2 interop channel: hdc shell cannot see the app sandbox, so the
      // export payload itself is mirrored to hilog in UTMB64 chunks (rebuilt
      // host-side into a real .utm for the Go parser cross-check).
      const helper = new util.Base64Helper();
      const b64 = helper.encodeToStringSync(stringToBytes(json), util.Type.BASIC);
      for (let ci = 0; ci < b64.length; ci += 3000) {
        hilog.info(IDOMAIN, ITAG, 'UTMB64 %{public}d %{public}s', ci, b64.substring(ci, ci + 3000));
      }`;
if (!t.includes(a)) { console.error('MISS'); process.exit(1); }
t = t.replace(a, b);
// stringToBytes helper (file likely has decodeUtf8 but not the encoder)
if (!t.includes('function stringToBytes')) {
  t += `
function stringToBytes(s: string): Uint8Array {
  const out: number[] = [];
  for (let i = 0; i < s.length; i++) {
    let cp = s.charCodeAt(i);
    if (cp < 0x80) {
      out.push(cp);
    } else if (cp < 0x800) {
      out.push(0xc0 | (cp >> 6), 0x80 | (cp & 0x3f));
    } else if (cp >= 0xd800 && cp <= 0xdbff && i + 1 < s.length) {
      const lo = s.charCodeAt(i + 1);
      if (lo >= 0xdc00 && lo <= 0xdfff) {
        cp = 0x10000 + ((cp - 0xd800) << 10) + (lo - 0xdc00);
        out.push(0xf0 | (cp >> 18), 0x80 | ((cp >> 12) & 0x3f), 0x80 | ((cp >> 6) & 0x3f), 0x80 | (cp & 0x3f));
        i++;
      } else {
        out.push(0xe0 | (cp >> 12), 0x80 | ((cp >> 6) & 0x3f), 0x80 | (cp & 0x3f));
      }
    } else {
      out.push(0xe0 | (cp >> 12), 0x80 | ((cp >> 6) & 0x3f), 0x80 | (cp & 0x3f));
    }
  }
  return new Uint8Array(out);
}
`;
}
fs.writeFileSync(path, t);
console.log('OK');
