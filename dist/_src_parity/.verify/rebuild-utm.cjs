// Rebuild .utm exported by the OHOS app from hilog UTMB64 chunks.
const fs = require('fs');
const src = process.argv[2];
const dst = process.argv[3];
const lines = fs.readFileSync(src, 'utf8').split(/\r?\n/);
const chunks = [];
for (const l of lines) {
  const m = l.match(/UTMB64 (\d+) ([A-Za-z0-9+/=]+)/);
  if (m) chunks.push([parseInt(m[1], 10), m[2]]);
}
if (chunks.length === 0) { console.error('no UTMB64 chunks'); process.exit(1); }
chunks.sort((a, b) => a[0] - b[0]);
// dedup (hilog -x may overlap windows)
const byOff = new Map();
for (const [off, data] of chunks) {
  if (!byOff.has(off)) byOff.set(off, data);
}
let b64 = '';
let expect = 0;
for (const off of [...byOff.keys()].sort((a, b) => a - b)) {
  if (off !== expect) { console.error('gap at', off, 'expected', expect); process.exit(1); }
  b64 += byOff.get(off);
  expect += byOff.get(off).length;
}
const json = Buffer.from(b64, 'base64').toString('utf8');
JSON.parse(json); // validity check
fs.writeFileSync(dst, json);
console.log('rebuilt', dst, json.length, 'bytes,', byOff.size, 'chunks');
