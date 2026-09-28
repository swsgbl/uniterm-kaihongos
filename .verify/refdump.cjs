// dump row/col deltas to understand REF structure from the UNCROPPED start_tab.png
const fs = require('fs');
const zlib = require('zlib');
function loadRaw(path) {
  const png = fs.readFileSync(path);
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
const px = (img, x, y) => { const i = (y * img.w + x) * img.ch; return [img.data[i], img.data[i + 1], img.data[i + 2]]; };
const lum = (img, x, y) => { const c = px(img, x, y); return (c[0] + c[1] + c[2]) / 3; };
function rowAvg(img, y, x0, x1) { let s = 0, n = 0; for (let x = x0; x < x1; x += 2) { s += lum(img, x, y); n++; } return s / n; }
function colAvg(img, x, y0, y1) { let s = 0, n = 0; for (let y = y0; y < y1; y += 2) { s += lum(img, x, y); n++; } return s / n; }

const img = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab.png');
console.log('start_tab.png', img.w + 'x' + img.h);
// row deltas in top 15%, x 60-90%
console.log('-- row deltas (x 60-90%):');
for (let y = 1; y < img.h * 0.15; y++) {
  const d = rowAvg(img, y, Math.floor(img.w * 0.6), Math.floor(img.w * 0.9)) - rowAvg(img, y - 1, Math.floor(img.w * 0.6), Math.floor(img.w * 0.9));
  if (Math.abs(d) > 1.0) console.log('  y=' + y + ' d=' + d.toFixed(1));
}
// col deltas in left 30%, y 15-95%
console.log('-- col deltas (y 15-95%):');
for (let x = 2; x < img.w * 0.3; x += 1) {
  const d = colAvg(img, x, Math.floor(img.h * 0.15), Math.floor(img.h * 0.95)) - colAvg(img, x - 2, Math.floor(img.h * 0.15), Math.floor(img.h * 0.95));
  if (Math.abs(d) > 1.5) console.log('  x=' + x + ' d=' + d.toFixed(1));
}
// corner + edge colors to find browser residue
console.log('corners:', [0, 0], px(img, 0, 0).join(','), [img.w - 1, 0], px(img, img.w - 1, 0).join(','), [0, img.h - 1], px(img, 0, img.h - 1).join(','));
