// M6 relay2: Index.ets hardcoded color cleanup
const fs = require('fs');
const f = 'D:/uniterm/kaihongos/entry/src/main/ets/pages/Index.ets';
let s = fs.readFileSync(f, 'utf8');
const before = s;
// L307: cardIconColor -> brand-based (returns hex string for gradient use)
s = s.replace("return '#22d3ee';", "return '#' + this.th().brand.toString(16).padStart(6, '0');");
// L514: theme label without navy
s = s.replace("Text(n === 'dark' ? '● 暗色' : (n === 'navy' ? '● 深蓝' : '● 浅色'))", "Text(n === 'dark' ? '● 暗色' : '● 浅色')");
// L631: Divider hardcoded cyan-ish -> subtle black hairline (works both themes)
s = s.replace(".color(this.themeName === 'light' ? '#1a000000' : '#2622d3ee')", ".color('rgba(0,0,0,0.10)')");
fs.writeFileSync(f, s);
const residual = (s.match(/#22d3ee|#2622d3ee|navy/g) || []).length;
console.log('changed:', s !== before, 'residual:', residual);
if (residual > 0) {
  const lines = s.split('\n');
  lines.forEach((l, i) => { if (/#22d3ee|navy/.test(l)) console.log(i + 1, l.trim().slice(0, 90)); });
}
