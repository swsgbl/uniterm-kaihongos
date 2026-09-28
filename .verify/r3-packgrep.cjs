const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
// check what the project needs: does pack_hap handle multi-module (entry+library HAR)? look at more of the script
console.log('=== pack_hap.sh middle (module handling) ===');
console.log(sh(HDC + 'shell "grep -n -i \'har\\|library\\|modules\\|hvigor\' /data/local/home/.local/bin/pack_hap.sh | head -40"').trim());
