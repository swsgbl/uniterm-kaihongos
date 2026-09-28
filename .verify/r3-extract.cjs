const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c, t) { try { return execSync(c, { encoding: 'utf8', timeout: t || 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== extract ===');
console.log(sh(HDC + 'shell "cd /data/local/home/tmp/app && tar xzf r3-src.tar.gz 2>&1 && echo EXTRACT_OK && ls"').trim());
console.log('=== oh-community signing files ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/app/thirdparty/signing/oh-community/"').trim());
console.log('=== har libs x86_64 ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/app/thirdparty/libssh-x86_64-har/libs/x86_64/"').trim());
console.log('=== entry libs ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/app/entry/libs/x86_64/ 2>/dev/null || echo none"').trim());
