const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c) { try { return execSync(c, { encoding: 'utf8', timeout: 60000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== toolchain bin ===');
console.log(sh(HDC + 'shell "ls /data/local/home/.local/bin/"').trim());
console.log('=== tmp ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/"').trim());
console.log('=== tmp/app ===');
console.log(sh(HDC + 'shell "ls /data/local/home/tmp/app/ 2>/dev/null || echo NO_APP_DIR"').trim());
console.log('=== dsh-pack node ===');
console.log(sh(HDC + 'shell "ls /data/local/home/dsh-pack/node/bin/ 2>/dev/null || echo NO_NODE"').trim());
console.log('=== 9p mount check ===');
console.log(sh(HDC + 'shell "mount | grep 9p || echo NO_9P_MOUNTED"').trim());
console.log(sh(HDC + 'shell "ls ~/hongfu 2>/dev/null | head -20 || echo NO_HONGFU_DIR"').trim());
