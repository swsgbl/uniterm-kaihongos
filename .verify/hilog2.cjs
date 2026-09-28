const { execSync } = require('child_process');
let out = '';
try {
  out = execSync('hdc -t 127.0.0.1:15566 shell "hilog -x"', { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, timeout: 60000 });
} catch (e) { out = (e.stdout || '') + (e.stderr || ''); }
const lines = out.split(/\r?\n/).filter(l => /uniterm|AbilityMS|appspawn|c1ace|A0f04|Fail|abort/i.test(l));
console.log(lines.slice(-50).join('\n'));
