// locate REF sidebar edge exactly: sample columns 340-420 at 55% height
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
const y = Math.floor(ref.h * 0.55);
let s = [];
for (let x = 330; x < 470; x += 6) s.push(x + ':' + hex(ref, x, y));
console.log('REF cols 330-470 @55%:', s.join(' '));
// also row scan inside sidebar for item rows (light rows)
const it = loadRaw('D:/uniterm/evidence/M5/relay2/iter2-crop.png');
let t = [];
const yi = Math.floor(it.h * 0.55);
for (let x = 150; x < 260; x += 6) t.push(x + ':' + hex(it, x, yi));
console.log('ITER cols 150-260 @55%:', t.join(' '));
