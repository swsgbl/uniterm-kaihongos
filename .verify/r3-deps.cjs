const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== entry/oh-package.json5 deps ===');
console.log(sh(HDC + 'shell "cat /data/local/home/tmp/app/entry/oh-package.json5"').trim());
console.log('=== root oh-package.json5 ===');
console.log(sh(HDC + 'shell "cat /data/local/home/tmp/app/oh-package.json5"').trim());
console.log('=== har oh-package ===');
console.log(sh(HDC + 'shell "cat /data/local/home/tmp/app/thirdparty/libssh-x86_64-har/oh-package.json5 2>/dev/null"').trim());
