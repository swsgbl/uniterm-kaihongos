const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== sig dir + profile json ===');
console.log(sh(HDC + 'shell "SIG=/data/local/home/.local/share/pack_hap/signing; ls $SIG 2>/dev/null || find /data/local/home -name app1-profile-release.json 2>/dev/null | head -3"').trim());
console.log('=== SDK api levels ===');
console.log(sh(HDC + 'shell "ls /data/local/home/.ohos/sdk/ 2>/dev/null"').trim());
console.log('=== hvigor wrapper exists? ===');
console.log(sh(HDC + 'shell "which hvigorw node ohos_packing_tool hap-sign-tool 2>&1"').trim());
console.log('=== 028 leftover project for reference ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/ 2>/dev/null; ls ~/MyApp 2>/dev/null | head -5; ls /data/local/home/ | head -20"').trim());
