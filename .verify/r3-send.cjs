const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('[1] mkdir app dir');
console.log(sh(HDC + 'shell "mkdir -p /data/local/home/tmp/app && echo OK"').trim());
console.log('[2] file send tar (21.8MB, may take a while)');
console.log(sh(HDC + 'file send D:\\uniterm\\.verify\\r3-src.tar.gz /data/local/home/tmp/app/r3-src.tar.gz', 600000).trim());
console.log('[3] verify size on device');
console.log(sh(HDC + 'shell "ls -l /data/local/home/tmp/app/r3-src.tar.gz"').trim());
