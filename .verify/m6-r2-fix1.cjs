// M6 relay2 fix1: revert .hairline( attribute calls to .border( (ArkUI builtin collision)
// + fix Index th() callable (th is a property in Index, not method)
const fs = require('fs');
const path = require('path');
const ROOT = 'D:/uniterm/kaihongos/entry/src/main/ets';
const files = [];
(function walk(d){ for (const e of fs.readdirSync(d,{withFileTypes:true})) {
  if (e.isDirectory()) walk(path.join(d,e.name)); else if (e.name.endsWith('.ets')) files.push(path.join(d,e.name));
}})(ROOT);
let attrFixes = 0, colonFixes = 0;
for (const f of files) {
  if (f.endsWith('AppTheme.ets')) continue;
  let s = fs.readFileSync(f,'utf8');
  const before = s;
  // ArkUI attribute call .hairline( -> .border(
  s = s.replace(/\.hairline\(/g, (m)=>{attrFixes++; return '.border(';});
  // object literal key hairline: { -> border: { (border style objects)
  s = s.replace(/\bhairline(\s*:\s*\{)/g, (m,g)=>{colonFixes++; return 'border'+g;});
  if (s !== before) { fs.writeFileSync(f,s); console.log(path.basename(f),'fixed'); }
}
// Index th property fix
const idx = path.join(ROOT,'pages/Index.ets');
let s = fs.readFileSync(idx,'utf8');
s = s.replace("return '#' + this.th().brand.toString(16).padStart(6, '0');", "return '#' + this.th.brand.toString(16).padStart(6, '0');");
fs.writeFileSync(idx,s);
console.log('attrFixes:',attrFixes,'colonFixes:',colonFixes);
// residual check: any .brand( / .hover( / .panel( / .ink( attribute misuse
let resid = 0;
for (const f of files) {
  const t = fs.readFileSync(f,'utf8');
  for (const m of t.match(/\.(brand|hover|panel|ink|inkSubtle|surface|surfaceRaised)\(/g)||[]) {
    console.log('SUSPECT', path.basename(f), m); resid++;
  }
}
console.log('suspect attribute calls:', resid);
