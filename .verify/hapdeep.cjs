// Deep compare OLD(ok) vs NEW(fail) hap zips: entries, sizes, hashes
const fs = require('fs');
const { execSync } = require('child_process');

function unzip(hap, dir) {
  fs.mkdirSync(dir, { recursive: true });
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  fs.copyFileSync(hap, dir + '/x.zip');
  execSync(`powershell -NoProfile -Command "Expand-Archive -LiteralPath ${dir.replace(/\//g, '/')}/x.zip -DestinationPath ${dir} -Force"`, { shell: 'cmd.exe' });
}

unzip('D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-default-oh-signed.hap', 'D:/uniterm/.verify/za');
unzip('D:/uniterm/kaihongos/entry/build/default/outputs/default/entry-default-oh-signed-m5r2.hap', 'D:/uniterm/.verify/zb');

const { createHash } = require('crypto');
function walk(d, base = d, acc = []) {
  for (const f of fs.readdirSync(d, { withFileTypes: true })) {
    const p = d + '/' + f.name;
    if (f.isDirectory()) walk(p, base, acc);
    else acc.push(p.substring(base.length + 1));
  }
  return acc;
}
const fa = walk('D:/uniterm/.verify/za'), fb = walk('D:/uniterm/.verify/zb');
const setA = new Set(fa), setB = new Set(fb);
console.log('only in OLD:', fa.filter(f => !setB.has(f)).join(', ') || '(none)');
console.log('only in NEW:', fb.filter(f => !setA.has(f)).join(', ') || '(none)');
let diffCount = 0;
for (const f of fa.filter(f => setB.has(f))) {
  const ha = createHash('sha256').update(fs.readFileSync('D:/uniterm/.verify/za/' + f)).digest('hex').slice(0, 12);
  const hb = createHash('sha256').update(fs.readFileSync('D:/uniterm/.verify/zb/' + f)).digest('hex').slice(0, 12);
  if (ha !== hb) { console.log('DIFF:', f, 'old=' + fs.statSync('D:/uniterm/.verify/za/' + f).size, 'new=' + fs.statSync('D:/uniterm/.verify/zb/' + f).size); diffCount++; }
}
console.log('total content diffs:', diffCount);
// pack.info apiVersion diff check
const pa = JSON.parse(fs.readFileSync('D:/uniterm/.verify/za/pack.info', 'utf8'));
const pb = JSON.parse(fs.readFileSync('D:/uniterm/.verify/zb/pack.info', 'utf8'));
console.log('OLD api:', JSON.stringify(pa.summary.modules[0].apiVersion));
console.log('NEW api:', JSON.stringify(pb.summary.modules[0].apiVersion));
const ma = JSON.parse(fs.readFileSync('D:/uniterm/.verify/za/module.json', 'utf8'));
const mb = JSON.parse(fs.readFileSync('D:/uniterm/.verify/zb/module.json', 'utf8'));
console.log('OLD minAPI:', ma.app.minAPIVersion, 'NEW:', mb.app.minAPIVersion);
console.log('OLD compileSdkType:', ma.app.compileSdkType, 'NEW:', mb.app.compileSdkType);
