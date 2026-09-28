const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== pack_hap.sh content ===');
console.log(sh(HDC + 'shell "cat /data/local/home/.local/bin/pack_hap.sh"').trim().slice(0, 2000));
console.log('=== pack_hap (first 60 lines) ===');
console.log(sh(HDC + 'shell "head -60 /data/local/home/.local/bin/pack_hap"').trim().slice(0, 3000));
