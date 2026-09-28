// point-sample colors in REF (start_tab.png) and ITER4
const fs = require('fs');
const zlib = require('zlib');
function loadRaw(p) {
  const png = fs.readFileSync(p);
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
function hexat(img, x, y) { const i = (y * img.w + x) * img.ch; return [img.data[i], img.data[i + 1], img.data[i + 2]].map(v => v.toString(16).padStart(2, '0')).join(''); }

const ref = loadRaw('D:/uniterm/evidence/M5/relay2/ref/start_tab.png');
console.log('REF(1546x1028):');
console.log(' header y40-60:', hexat(ref, 900, 45), hexat(ref, 1200, 60), '| sidebar y300:', hexat(ref, 100, 300), hexat(ref, 190, 700), '| main:', hexat(ref, 900, 300), hexat(ref, 1200, 700));
console.log(' edge x220-230 y500:', [220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230].map(x => hexat(ref, x, 500)).join(' '));
console.log(' header-bottom y70-78 x900:', [70, 71, 72, 73, 74, 75, 76, 77, 78].map(y => hexat(ref, 900, y)).join(' '));
console.log(' sidebar-line y200..800 x224:', [200, 300, 400, 500, 600, 700, 800, 900].map(y => hexat(ref, 224, y)).join(' '));

const it = loadRaw('D:/uniterm/evidence/M5/relay2/iter4-start.png');
console.log('ITER4(1600x900), content origin ~x2,y32:');
console.log(' header:', hexat(it, 800, 45), hexat(it, 1000, 55), '| sidebar:', hexat(it, 100, 300), hexat(it, 200, 600), '| main:', hexat(it, 900, 300), hexat(it, 1200, 700));
