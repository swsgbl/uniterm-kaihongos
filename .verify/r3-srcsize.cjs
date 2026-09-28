const { execSync } = require('child_process');
const fs = require('fs');
// What's big in the source tree (excluding build dirs)?
const { execFileSync } = require('child_process');
const out = execFileSync('powershell', ['-NoProfile', '-Command',
  "Get-ChildItem 'D:\\uniterm\\kaihongos' -Recurse -File -ErrorAction SilentlyContinue | Where-Object {$_.FullName -notmatch '\\\\(build|oh_modules|\\.hvigor|\\.git)\\\\'} | Sort-Object Length -Descending | Select-Object -First 25 | ForEach-Object { '{0,10} {1}' -f [math]::Round($_.Length/1MB,2), $_.FullName }"],
  { encoding: 'utf8' });
console.log(out);
// per-top-level-dir sizes
const out2 = execFileSync('powershell', ['-NoProfile', '-Command',
  "Get-ChildItem 'D:\\uniterm\\kaihongos' -Directory | ForEach-Object { $s=(Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; '{0,10} {1}' -f [math]::Round($s/1MB,1), $_.Name }"],
  { encoding: 'utf8' });
console.log(out2);
