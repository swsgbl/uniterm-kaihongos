// analyze the user's PRIMARY baseline: evidence/ui-parity/ref-official.png
const fs = require('fs');
const zlib = require('zlib');
function loadRaw(p) {
  const png = fs.readFileSync(p);
  const width = png.readUInt32BE(16), height = png.readUInt32BE(20);
  let idat = [], off = 8;
  while (off < png.length) {
    const len = png.readUInt32BE(off);
    if (png.toString('ascii', off + 4, off + 8) === 'IDAT') idat.push(png.subarray(off + 8, off + 8 + len));
    off += 12 + len;
  }
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const ch = png[25] === 6 ? 4 : 3, stride = width * ch;
  const out = Buffer.alloc(height * stride);
  let pos = 0, prev = Buffer.alloc(stride);
  for (let y = 0; y < height; y++) {
    const filter = raw[pos++];
    const line = raw.subarray(pos, pos + stride); pos += stride;
    const cur = out.subarray(y * stride, (y + 1) * stride);
    for (let x = 0; x < stride; x++) {
      const a = x >= ch ? cur[x - ch] : 0, b = prev[x], c = x >= ch ? prev[x - ch] : 0;
      let v = line[x];
      switch (filter) {
        case 1: v = (v + a) & 255; break;
        case 2: v = (v + b) & 255; break;
        case 3: v = (v + ((a + b) >> 1)) & 255; break;
        case 4: { const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c); v = (v + (pa <= pb && pa <= pc ? a : (pb <= pc ? b : c))) & 255; break; }
      }
      cur[x] = v;
    }
    prev = cur;
  }
  return { w: width, h: height, ch, data: out };
}
const lum = (img, x, y) => { const i = (y * img.w + x) * img.ch; return (img.data[i] + img.data[i + 1] + img.data[i + 2]) / 3; };
const hexat = (img, x, y) => { const i = (y * img.w + x) * img.ch; return [img.data[i], img.data[i + 1], img.data[i + 2]].map(v => v.toString(16).padStart(2, '0')).join(''); };
function rowAvg(img, y, x0, x1) { let s = 0, n = 0; for (let x = x0; x < x1; x += 2) { s += lum(img, x, y); n++; } return s / n; }
function colAvg(img, x, y0, y1) { let s = 0, n = 0; for (let y = y0; y < y1; y += 2) { s += lum(img, x, y); n++; } return s / n; }

const img = loadRaw('D:/uniterm/evidence/ui-parity/ref-official.png');
console.log('ref-official.png', img.w + 'x' + img.h);
// app top edge
let appTop = 0;
for (let y = 1; y < 80; y++) { const d = rowAvg(img, y, Math.floor(img.w * 0.6), Math.floor(img.w * 0.9)) - rowAvg(img, y - 1, Math.floor(img.w * 0.6), Math.floor(img.w * 0.9)); if (d < -30) { appTop = y; console.log('app top edge y=' + y + ' d=' + d.toFixed(0)); break; } }
// header bottom
for (let y = appTop + 10; y < appTop + 120; y++) { const d = rowAvg(img, y, Math.floor(img.w * 0.6), Math.floor(img.w * 0.9)) - rowAvg(img, y - 1, Math.floor(img.w * 0.6), Math.floor(img.w * 0.9)); if (Math.abs(d) > 4) console.log('row delta y=' + y + ' (+' + (y - appTop) + ') d=' + d.toFixed(1)); }
// sidebar right edge
const sy0 = appTop + 100, sy1 = img.h - 40;
for (let x = 20; x < img.w * 0.35; x++) { const d = colAvg(img, x, sy0, sy1) - colAvg(img, x - 2, sy0, sy1); if (Math.abs(d) > 4) console.log('col delta x=' + x + ' d=' + d.toFixed(1) + ' frac=' + (x / img.w).toFixed(4)); }
// colors
console.log('header bg:', hexat(img, Math.floor(img.w * 0.55), appTop + 20), hexat(img, Math.floor(img.w * 0.85), appTop + 25));
console.log('sidebar bg:', hexat(img, 100, Math.floor(img.h * 0.5)), hexat(img, 150, Math.floor(img.h * 0.7)));
console.log('main bg:', hexat(img, Math.floor(img.w * 0.6), Math.floor(img.h * 0.35)), hexat(img, Math.floor(img.w * 0.85), Math.floor(img.h * 0.9)));
// sidebar text bands (density)
const bands = []; let cur = null;
for (let y = appTop + 80; y < img.h - 30; y++) {
  let mn = 999, mx = -1;
  for (let x = 30; x < 220; x += 2) { const v = lum(img, x, y); if (v < mn) mn = v; if (v > mx) mx = v; }
  const v = mx - mn;
  if (v > 16) { if (!cur) cur = { y0: y, y1: y, v }; else { cur.y1 = y; cur.v = Math.max(cur.v, v); } }
  else if (cur) { if (cur.y1 - cur.y0 >= 3) bands.push(cur); cur = null; }
}
if (cur && cur.y1 - cur.y0 >= 3) bands.push(cur);
console.log('sidebar bands(' + bands.length + '):', JSON.stringify(bands.map(b => b.y0 + '-' + b.y1)));
console.log('bandH:', JSON.stringify(bands.map(b => b.y1 - b.y0)), 'gaps:', JSON.stringify(bands.slice(1).map((b, i) => b.y0 - bands[i].y1 - 1)));
