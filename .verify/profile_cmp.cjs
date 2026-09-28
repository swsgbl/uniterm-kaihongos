// Programmatic layout comparison: ref vs iter via pixel profiles
const fs = require('fs');
const { execSync } = require('child_process');

const REF = 'D:/uniterm/evidence/M5/relay2/ref/start_tab-crop.png';
const IT = 'D:/uniterm/evidence/M5/relay2/iter2-crop.png';

function loadRaw(path, w, h) {
  const png = fs.readFileSync(path);
  const zlib = require('zlib');
  // find IHDR
  const width = png.readUInt32BE(16), height = png.readUInt32BE(20);
  const bitDepth = png[24], colorType = png[25];
  // concat IDAT
  let idat = [];
  let off = 8;
  while (off < png.length) {
    const len = png.readUInt32BE(off);
    const type = png.toString('ascii', off + 4, off + 8);
    if (type === 'IDAT') idat.push(png.subarray(off + 8, off + 8 + len));
    off += 12 + len;
  }
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const ch = colorType === 6 ? 4 : 3;
  // unfilter
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

function px(img, x, y) {
  const i = (y * img.w + x) * img.ch;
  return [img.data[i], img.data[i + 1], img.data[i + 2]];
}
function lum(img, x, y) { const [r, g, b] = px(img, x, y); return (r + g + b) / 3; }

const ref = loadRaw(REF), it = loadRaw(IT);
console.log('ref:', ref.w + 'x' + ref.h, ' iter:', it.w + 'x' + it.h);

// Detect sidebar width: scan for the vertical border column where bg changes
function colProfile(img, y0, y1) {
  // avg luminance per column band
  const prof = [];
  for (let x = 0; x < img.w; x += 4) {
    let s = 0, n = 0;
    for (let y = y0; y < y1; y += 8) { s += lum(img, x, y); n++; }
    prof.push({ x, v: s / n });
  }
  return prof;
}
// find rightmost dark-ish then step to darker in left 30% (sidebar boundary)
function findSidebarEdge(img) {
  const p = colProfile(img, Math.floor(img.h * 0.3), Math.floor(img.h * 0.9));
  let bestX = -1, bestJump = 0;
  for (let i = 1; i < p.length * 0.4; i++) {
    const jump = Math.abs(p[i].v - p[i - 1].v);
    if (jump > bestJump) { bestJump = jump; bestX = p[i].x; }
  }
  return { bestX, bestJump, sample: p.slice(0, 30).map(q => q.x + ':' + Math.round(q.v)).join(' ') };
}
console.log('REF sidebar edge:', JSON.stringify(findSidebarEdge(ref)));
console.log('ITER sidebar edge:', JSON.stringify(findSidebarEdge(it)));

// header height: scan rows in first 15% height for horizontal divider line (light accent)
function rowProfile(img, x0, x1) {
  const prof = [];
  for (let y = 0; y < Math.floor(img.h * 0.2); y += 2) {
    let s = 0, n = 0;
    for (let x = x0; x < x1; x += 8) { s += lum(img, x, y); n++; }
    prof.push({ y, v: s / n });
  }
  return prof;
}
const rp = rowProfile(ref, Math.floor(ref.w * 0.5), Math.floor(ref.w * 0.9));
const ip = rowProfile(it, Math.floor(it.w * 0.5), Math.floor(it.w * 0.9));
console.log('REF rows:', rp.map(q => q.y + ':' + Math.round(q.v)).join(' '));
console.log('ITER rows:', ip.map(q => q.y + ':' + Math.round(q.v)).join(' '));
