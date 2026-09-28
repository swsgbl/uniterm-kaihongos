// locate iter3 sidebar width via dumpLayout-free pixel scan: find rightmost content column in left 30%
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
const lum = (img, x, y) => { const i = (y * img.w + x) * img.ch; return (img.data[i] + img.data[i + 1] + img.data[i + 2]) / 3; };

const ref = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab-crop.png');
const it = loadRaw('D:/uniterm/evidence/M5/relay2/iter3-crop.png');

// For each column in left 40%, compute vertical variance (text/icons have variance)
function colVar(img, x, y0, y1) {
  let s = 0, s2 = 0, n = 0;
  for (let y = y0; y < y1; y += 3) { const v = lum(img, x, y); s += v; s2 += v * v; n++; }
  const m = s / n;
  return s2 / n - m * m;
}
function sidebarWidth(img) {
  const y0 = Math.floor(img.h * 0.15), y1 = Math.floor(img.h * 0.95);
  const maxX = Math.floor(img.w * 0.4);
  let lastContent = 0;
  for (let x = 4; x < maxX; x += 2) {
    if (colVar(img, x, y0, y1) > 8) lastContent = x;
  }
  return lastContent;
}
console.log('REF sidebar content extends to x=', sidebarWidth(ref), ' of', ref.w, ' => frac', Math.round(sidebarWidth(ref) / ref.w * 1000) / 10, '%');
console.log('IT3 sidebar content extends to x=', sidebarWidth(it), ' of', it.w, ' => frac', Math.round(sidebarWidth(it) / it.w * 1000) / 10, '%');
