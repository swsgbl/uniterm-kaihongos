// iter4 vs ref structural comparison v2: skip window/crop edges, use strong deltas + color columns
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
function topColor(img, x0, y0, x1, y1) {
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

function analyze(name, img, ox, oy) {
  const W = img.w - ox, H = img.h - oy; // content dims
  const X = f => ox + Math.floor(W * f), Y = f => oy + Math.floor(H * f);
  const out = { name, W, H };
  // header bottom: strongest row delta in top 20%, main x 60-90%
  let hdr = null;
  for (let y = oy + 4; y < Y(0.2); y++) {
    const d = rowAvg(img, y, X(0.6), X(0.9)) - rowAvg(img, y - 1, X(0.6), X(0.9));
    if (!hdr || Math.abs(d) > Math.abs(hdr.d)) hdr = { y: y - oy, d: Math.round(d * 10) / 10 };
  }
  out.headerBottom = hdr;
  // sidebar right edge: strongest col delta in x [40px..35%], y below header+20
  const sy0 = oy + hdr.y + 20, sy1 = Y(0.96);
  let sbe = null;
  for (let x = ox + 40; x < X(0.35); x++) {
    const d = colAvg(img, x, sy0, sy1) - colAvg(img, x - 2, sy0, sy1);
    if (Math.abs(d) > 2 && (!sbe || Math.abs(d) > Math.abs(sbe.d))) sbe = { x: x - ox, d: Math.round(d * 10) / 10 };
  }
  out.sidebarEdge = sbe;
  out.sidebarPx = sbe ? sbe.x : null;
  // colors
  out.cHeader = topColor(img, X(0.62), oy + 2, X(0.9), oy + Math.max(4, hdr.y - 2));
  out.cSidebar = topColor(img, ox + 40, Y(0.5), ox + Math.floor((sbe ? sbe.x : 300) * 0.7), Y(0.9));
  out.cMain = topColor(img, X(0.5), Y(0.5), X(0.92), Y(0.92));
  // sidebar bands: variance rows in [x 45..sidebarEdge-10]
  const czX0 = ox + 45, czX1 = ox + (sbe ? sbe.x - 8 : Math.floor(W * 0.2));
  const bands = []; let cur = null;
  for (let y = sy0; y < sy1; y++) {
    let mn = 999, mx = -1;
    for (let x = czX0; x < czX1; x += 2) { const v = lum(img, x, y); if (v < mn) mn = v; if (v > mx) mx = v; }
    const v = mx - mn;
    if (v > 16) { if (!cur) cur = { y0: y - oy, y1: y - oy, v }; else { cur.y1 = y - oy; cur.v = Math.max(cur.v, v); } }
    else if (cur) { if (cur.y1 - cur.y0 >= 3) bands.push(cur); cur = null; }
  }
  if (cur && cur.y1 - cur.y0 >= 3) bands.push(cur);
  out.bands = bands.map(b => b.y0 + '-' + b.y1);
  out.bandHeights = bands.map(b => b.y1 - b.y0);
  out.bandGaps = bands.slice(1).map((b, i) => b.y0 - bands[i].y1 - 1);
  return out;
}

const ref = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab-crop.png');
const it4 = loadRaw('D:/uniterm/evidence/M5/relay2/iter4-start.png');
const R = analyze('REF', ref, 26, 0);
const I = analyze('ITER4', it4, 2, 32);
for (const o of [R, I]) {
  console.log('=== ' + o.name + ' content ' + o.W + 'x' + o.H);
  console.log(' headerBottom y=' + JSON.stringify(o.headerBottom) + ' frac=' + (o.headerBottom.y / o.H).toFixed(4));
  console.log(' sidebarEdge x=' + JSON.stringify(o.sidebarEdge) + ' frac=' + (o.sidebarEdge && o.sidebarEdge.x / o.W).toFixed(4));
  console.log(' colors hdr=' + o.cHeader + ' side=' + o.cSidebar + ' main=' + o.cMain);
  console.log(' bands(' + o.bands.length + '): ' + JSON.stringify(o.bands));
  console.log(' bandH:' + JSON.stringify(o.bandHeights) + ' gaps:' + JSON.stringify(o.bandGaps));
}
