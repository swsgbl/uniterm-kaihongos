// M5 relay2: compare installed bundle vs our new hap - signature material
// usage: node sigcmp.cjs
const fs = require('fs');
const cp = require('child_process');

function sh(cmd) {
  try { return cp.execSync(cmd, { shell: 'cmd.exe', encoding: 'utf8' }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); }
}

// 1. installed appId/provision
const bm = fs.readFileSync('D:/uniterm/.verify/_hapold/bm-installed.json', 'utf8').replace(/^net\.uniterm\.poc:\s*/m, '');
const j = JSON.parse(bm);
console.log('== installed ==');
console.log('appId:', j.appId);
console.log('appProvisionType:', j.applicationInfo && j.applicationInfo.appProvisionType);
console.log('appDistributionType:', j.applicationInfo && j.applicationInfo.appDistributionType);

// 2. extract profile p7b from old (device-accepted) signed hap vs our new
for (const [name, dir] of [['OLD(ok)', 'D:/uniterm/.verify/_hapold'], ['NEW(fail)', 'D:/uniterm/.verify/_hapnew2']]) {
  const files = fs.readdirSync(dir);
  const p7b = files.filter(f => f.endsWith('.p7b'));
  console.log(`\n== ${name} == dir files:`, files.filter(f => !f.endsWith('.abc') && !f.endsWith('.so')).slice(0, 20).join(','));
  const prof = fs.readdirSync(dir).find(f => /profile/i.test(f));
  if (prof) {
    const buf = fs.readFileSync(dir + '/' + prof);
    console.log(name, 'profile file:', prof, 'size:', buf.length);
    const s = buf.toString('latin1');
    const certCount = (s.match(/-----BEGIN CERTIFICATE-----/g) || []).length;
    const derCount = (s.match(/\x30\x82/g) || []).length;
    console.log(name, 'pem cert blocks:', certCount);
    // app identifier strings inside p7b
    const strMatches = s.match(/[ -~]{12,}/g) || [];
    const interesting = strMatches.filter(x => /uniterm|OpenHarmony|ide_demo|distribution|app-feature|apl/i.test(x));
    console.log(name, 'p7b strings:', interesting.slice(0, 12));
  }
  const sig = fs.readdirSync(dir).find(f => /^signature$/i.test(f) || /META-INF.*[RS]SA|CERT/i.test(f));
  if (sig) console.log(name, 'sig file:', sig);
  const mf = fs.readdirSync(dir).find(f => f.toLowerCase() === 'manifest.bin' || f.toLowerCase().includes('manifest'));
  console.log(name, 'manifest-ish:', fs.readdirSync(dir).join(','));
}
