// Correct sidebar detection: the connection tree rows are dark-on-dark; instead find the
// vertical border line (slightly lighter than both sides) between sidebar and main.
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

// scan columns: find where a persistent 1-2px vertical divider exists (col brighter than neighbors over most rows)
function findDivider(img) {
  const y0 = Math.floor(img.h * 0.25), y1 = Math.floor(img.h * 0.9);
  const hits = [];
  for (let x = 6; x < img.w * 0.45; x++) {
    let brighter = 0, n = 0;
    for (let y = y0; y < y1; y += 4) {
      const c = lum(img, x, y), l = lum(img, x - 3, y), r = lum(img, x + 3, y);
      if (c > l + 2 && c > r + 2) brighter++;
      n++;
    }
    if (brighter / n > 0.7) hits.push(x);
  }
  // cluster
  const clusters = [];
  for (const x of hits) {
    if (clusters.length && x - clusters[clusters.length - 1][clusters[clusters.length - 1].length - 1] <= 3) clusters[clusters.length - 1].push(x);
    else clusters.push([x]);
  }
  return clusters.map(c => c[0] + '~' + c[c.length - 1]);
}
console.log('REF dividers:', findDivider(ref).join(' , '));
console.log('IT3 dividers:', findDivider(it).join(' , '));
