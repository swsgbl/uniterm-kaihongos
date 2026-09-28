// iter4 vs ref comprehensive structural comparison (fractions + colors + density)
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
const hex = c => '#' + c.map(v => v.toString(16).padStart(2, '0')).join('');

function colAvg(img, x, y0, y1) { let s = 0, n = 0; for (let y = y0; y < y1; y += 2) { s += lum(img, x, y); n++; } return s / n; }
function rowAvg(img, y, x0, x1) { let s = 0, n = 0; for (let x = x0; x < x1; x += 2) { s += lum(img, x, y); n++; } return s / n; }

// median color of a region (robust bg sampling)
function regionMedian(img, x0, y0, x1, y1) {
  const list = [];
  for (let y = y0; y < y1; y += 2) for (let x = x0; x < x1; x += 2) list.push(lum(img, x, y));
  list.sort((a, b) => a - b);
  return list[Math.floor(list.length / 2)];
}
function regionColor(img, x0, y0, x1, y1) {
  // pick most frequent quantized color
  const counts = new Map();
  for (let y = y0; y < y1; y += 2) for (let x = x0; x < x1; x += 2) {
    const c = px(img, x, y); const key = (c[0] >> 3) + ',' + (c[1] >> 3) + ',' + (c[2] >> 3);
    const e = counts.get(key) || { n: 0, r: 0, g: 0, b: 0 };
    e.n++; e.r += c[0]; e.g += c[1]; e.b += c[2]; counts.set(key, e);
  }
  let best = null;
  for (const e of counts.values()) if (!best || e.n > best.n) best = e;
  if (!best) return 'n/a';
  return hex([Math.round(best.r / best.n), Math.round(best.g / best.n), Math.round(best.b / best.n)]);
}

function analyze(name, img) {
  const out = { name, w: img.w, h: img.h };
  // 1. header bottom edge: scan rows in main area (right 60-92%)
  const x0 = Math.floor(img.w * 0.55), x1 = Math.floor(img.w * 0.92);
  for (let y = 6; y < img.h * 0.3; y++) {
    const d = rowAvg(img, y, x0, x1) - rowAvg(img, y - 1, x0, x1);
    if (Math.abs(d) > 1.5) { out.headerH = y; out.headerD = Math.round(d * 10) / 10; break; }
  }
  out.headerHf = +(out.headerH / img.h).toFixed(4);
  // 2. sidebar right boundary: strongest col edge in left 35%, below header
  const sy0 = (out.headerH || 40) + 30, sy1 = Math.floor(img.h * 0.95);
  let bestEdge = null;
  for (let x = 10; x < img.w * 0.35; x++) {
    const d = colAvg(img, x, sy0, sy1) - colAvg(img, x - 2, sy0, sy1);
    if (Math.abs(d) > 1.0 && (!bestEdge || Math.abs(d) > Math.abs(bestEdge.d))) bestEdge = { x, d: Math.round(d * 10) / 10 };
  }
  out.sidebarEdge = bestEdge; out.sidebarFrac = bestEdge ? +(bestEdge.x / img.w).toFixed(4) : null;
  // 3. colors
  out.bgHeader = regionColor(img, Math.floor(img.w * 0.6), 4, Math.floor(img.w * 0.9), (out.headerH || 40) - 4);
  out.bgSidebar = regionColor(img, 20, Math.floor(img.h * 0.5), Math.floor((bestEdge ? bestEdge.x : img.w * 0.2) * 0.7), Math.floor(img.h * 0.9));
  out.bgMain = regionColor(img, Math.floor(img.w * 0.5), Math.floor(img.h * 0.5), Math.floor(img.w * 0.9), Math.floor(img.h * 0.92));
  // 4. sidebar text row density: rows with horizontal variance in sidebar content zone
  const czX0 = Math.floor(img.w * 0.01), czX1 = Math.floor((bestEdge ? bestEdge.x : img.w * 0.2) * 0.9);
  const rowV = [];
  for (let y = sy0; y < sy1; y++) {
    let mn = 999, mx = -1;
    for (let x = czX0; x < czX1; x += 2) { const v = lum(img, x, y); if (v < mn) mn = v; if (v > mx) mx = v; }
    rowV.push({ y, v: mx - mn });
  }
  // contiguous bands with variance > 18 = text rows
  const bands = []; let cur = null;
  for (const r of rowV) {
    if (r.v > 18) { if (!cur) cur = { y0: r.y, y1: r.y }; else cur.y1 = r.y; }
    else if (cur) { if (cur.y1 - cur.y0 >= 3) bands.push(cur); cur = null; }
  }
  if (cur && cur.y1 - cur.y0 >= 3) bands.push(cur);
  out.sidebarTextBands = bands.length;
  out.sidebarBandGaps = bands.slice(1, 12).map((b, i) => b.y0 - bands[i].y1);
  // first bands positions
  out.firstBands = bands.slice(0, 14).map(b => b.y0 + '-' + b.y1);
  return out;
}

const ref = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab-crop.png');
const it4 = loadRaw('D:/uniterm/evidence/M5/relay2/iter4-start.png');
console.log(JSON.stringify(analyze('REF', ref), null, 1));
console.log(JSON.stringify(analyze('ITER4', it4), null, 1));
