// iter3 vs ref: same analysis as edge2 but pointing at iter3
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
const hex = (img, x, y) => { const i = (y * img.w + x) * img.ch; return '#' + [img.data[i], img.data[i + 1], img.data[i + 2]].map(v => v.toString(16).padStart(2, '0')).join(''); };
const ref = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab-crop.png');
const it = loadRaw('D:/uniterm/evidence/M5/relay2/iter3-crop.png');
console.log('ref:', ref.w + 'x' + ref.h, 'iter3:', it.w + 'x' + it.h);
const y1 = Math.floor(ref.h * 0.55), y2 = Math.floor(it.h * 0.55);
let s1 = [], s2 = [];
for (let x = 300; x < 480; x += 8) s1.push(x + ':' + hex(ref, x, y1));
for (let x = 200; x < 400; x += 8) s2.push(x + ':' + hex(it, x, y2));
console.log('REF cols@55%:', s1.join(' '));
console.log('IT3 cols@55%:', s2.join(' '));
// sidebar boundary in iter3
let t = [];
for (let x = 240; x < 340; x += 4) t.push(x + ':' + hex(it, x, y2));
console.log('IT3 boundary:', t.join(' '));
