const { execSync } = require('child_process');
const HDC = 'hdc -t 127.0.0.1:15566 ';
function sh(c) { try { return execSync(c, { encoding: 'utf8', timeout: 120000 }); } catch (e) { return (e.stdout || '') + (e.stderr || ''); } }
console.log('=== kernel 9p support ===');
console.log(sh(HDC + 'shell "zcat /proc/config.gz 2>/dev/null | grep -i 9p ; ls /proc/filesystems | grep 9p ; cat /proc/filesystems | grep 9p || echo NO_9P_IN_FILESYSTEMS"').trim());
console.log('=== net modules ===');
console.log(sh(HDC + 'shell "ls /lib/modules/$(uname -r)/ 2>/dev/null | head -5 || echo NO_MODULES_DIR"').trim());
console.log('=== uname ===');
console.log(sh(HDC + 'shell "uname -a"').trim());
console.log('=== try modprobe ===');
console.log(sh(HDC + 'shell "modprobe 9p 2>&1; modprobe 9pnet_virtio 2>&1; echo MODPROBE_DONE"').trim());
console.log('=== retry mount ===');
console.log(sh(HDC + 'shell "mount -t 9p -o trans=virtio,version=9p2000.L Public-hongfu /data/local/home/hongfu && echo MOUNT_OK || echo STILL_FAIL"').trim());
