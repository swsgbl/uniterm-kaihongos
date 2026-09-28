// precise structure: locate ref sidebar right edge & header height via column/row deltas
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
  const ch = png[25] === 6 ? 4 : 3;
  const stride = width * ch;
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
const it = loadRaw('D:/uniterm/evidence/M5/relay2/iter2-crop.png');

// REF: find vertical line in left half = sidebar/main boundary (border color slightly lighter)
function colAvg(img, x, y0, y1) {
  let s = 0, n = 0;
  for (let y = y0; y < y1; y += 4) { s += lum(img, x, y); n++; }
  return s / n;
}
function findBoundary(img, maxFrac) {
  const y0 = Math.floor(img.h * 0.35), y1 = Math.floor(img.h * 0.95);
  const maxX = Math.floor(img.w * maxFrac);
  let edges = [];
  for (let x = 8; x < maxX; x += 2) {
    const d = colAvg(img, x, y0, y1) - colAvg(img, x - 4, y0, y1);
    if (Math.abs(d) > 1.2) edges.push({ x, d: Math.round(d * 10) / 10 });
  }
  return edges.slice(0, 12);
}
console.log('REF col edges (left 35%):', JSON.stringify(findBoundary(ref, 0.35)));
console.log('ITER col edges (left 35%):', JSON.stringify(findBoundary(it, 0.35)));

// header: row where luminance steps (header bg vs main bg)
function rowAvg(img, y, x0, x1) {
  let s = 0, n = 0;
  for (let x = x0; x < x1; x += 4) { s += lum(img, x, y); n++; }
  return s / n;
}
function findHeaderEdge(img) {
  const x0 = Math.floor(img.w * 0.6), x1 = Math.floor(img.w * 0.92);
  let out = [];
  for (let y = 4; y < Math.floor(img.h * 0.25); y += 2) {
    const d = rowAvg(img, y, x0, x1) - rowAvg(img, y - 2, x0, x1);
    if (Math.abs(d) > 1.0) out.push({ y, d: Math.round(d * 10) / 10 });
  }
  return out.slice(0, 12);
}
console.log('REF header row edges:', JSON.stringify(findHeaderEdge(ref)));
console.log('ITER header row edges:', JSON.stringify(findHeaderEdge(it)));
