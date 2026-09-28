const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log(sh(HDC + 'shell "sed -n 170,320p /data/local/home/.local/bin/pack_hap.sh"').trim());
