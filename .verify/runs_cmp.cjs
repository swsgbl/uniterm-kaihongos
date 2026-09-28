// Find sidebar right-edge & header structure via column color variance
const fs = require('fs');
const zlib = require('zlib');

function loadRaw(path) {
  const png = fs.readFileSync(path);
  const width = png.readUInt32BE(16), height = png.readUInt32BE(20);
  let idat = [];
  let off = 8;
  while (off < png.length) {
    const len = png.readUInt32BE(off);
    const type = png.toString('ascii', off + 4, off + 8);
    if (type === 'IDAT') idat.push(png.subarray(off + 8, off + 8 + len));
    off += 12 + len;
  }
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const ch = png[25] === 6 ? 4 : 3;
  const stride = width * ch;
  const out = Buffer.alloc(height * stride);
  let pos = 0;
  let prev = Buffer.alloc(stride);
  for (let y = 0; y < height; y++) {
    const filter = raw[pos++];
    const line = raw.subarray(pos, pos + stride); pos += stride;
    const cur = out.subarray(y * stride, (y + 1) * stride);
    for (let x = 0; x < stride; x++) {
      const a = x >= ch ? cur[x - ch] : 0;
      const b = prev[x];
      const c = x >= ch ? prev[x - ch] : 0;
      let v = line[x];
      switch (filter) {
        case 1: v = (v + a) & 255; break;
        case 2: v = (v + b) & 255; break;
        case 3: v = (v + ((a + b) >> 1)) & 255; break;
        case 4: { const p = a + b - c; const pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c); v = (v + (pa <= pb && pa <= pc ? a : (pb <= pc ? b : c))) & 255; break; }
      }
      cur[x] = v;
    }
    prev = cur;
  }
  return { w: width, h: height, ch, data: out };
}
const px = (img, x, y) => { const i = (y * img.w + x) * img.ch; return [img.data[i], img.data[i + 1], img.data[i + 2]]; };
const hex = (img, x, y) => { const [r, g, b] = px(img, x, y); return '#' + [r, g, b].map(v => v.toString(16).padStart(2, '0')).join(''); };

const ref = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab-crop.png');
const it = loadRaw('D:/uniterm/evidence/M5/relay2/iter2-crop.png');

// scan a horizontal line at 60% height: print color runs > 8px
function runs(img, y) {
  const out = [];
  let start = 0, cur = hex(img, 0, y);
  for (let x = 4; x < img.w; x += 4) {
    const c = hex(img, x, y);
    if (c !== cur) {
      if (x - start >= 12) out.push(start + '-' + x + ':' + cur);
      start = x; cur = c;
    }
  }
  out.push(start + '-end:' + cur);
  return out;
}
console.log('REF y=55%:', runs(ref, Math.floor(ref.h * 0.55)).join(' '));
console.log('ITER y=55%:', runs(it, Math.floor(it.h * 0.55)).join(' '));
console.log('REF y=12%:', runs(ref, Math.floor(ref.h * 0.12)).join(' '));
console.log('ITER y=12%:', runs(it, Math.floor(it.h * 0.12)).join(' '));
// sample main colors
console.log('REF main bg:', hex(ref, Math.floor(ref.w * 0.7), Math.floor(ref.h * 0.7)), ' header:', hex(ref, Math.floor(ref.w * 0.7), 20), ' side:', hex(ref, 100, Math.floor(ref.h * 0.5)));
console.log('ITER main bg:', hex(it, Math.floor(it.w * 0.7), Math.floor(it.h * 0.7)), ' header:', hex(it, Math.floor(it.w * 0.7), 20), ' side:', hex(it, 100, Math.floor(it.h * 0.5)));
