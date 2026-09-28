const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c) { try { return execSync(c, { encoding: 'utf8', timeout: 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
// try 9p mount (root via hdc shell is usually root on this VM)
console.log('=== whoami ===');
console.log(sh(HDC + 'shell "whoami; id"').trim());
console.log('=== try mount 9p ===');
console.log(sh(HDC + 'shell "mkdir -p /data/local/home/hongfu && mount -t 9p -o trans=virtio,version=9p2000.L Public-hongfu /data/local/home/hongfu && echo MOUNT_OK || echo MOUNT_FAIL"').trim());
console.log('=== ls mount ===');
console.log(sh(HDC + 'shell "ls /data/local/home/hongfu/ 2>/dev/null | head -20 || echo EMPTY"').trim());
