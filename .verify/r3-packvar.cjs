const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== pack_hap.sh SIG var definition ===');
console.log(sh(HDC + 'shell "grep -n \'SIG=\\|UNSIGNED=\\|SIGNED=\\|INTER=\\|MODULE_JSON=\\|OUT=\\|ABI=\\|API_LEVEL=\' /data/local/home/.local/bin/pack_hap.sh | head -20"').trim());
console.log('=== which (login shell) ===');
console.log(sh(HDC + 'shell "source /data/local/home/env.sh >/dev/null 2>&1; which hvigorw node ohos_packing_tool hap-sign-tool"').trim());
console.log('=== 028 previous build evidence on device ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/app/ | head; find /data/local/home/tmp -name \'*.hap\' 2>/dev/null | head -10"').trim());
