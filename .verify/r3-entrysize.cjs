const { execFileSync } = require('child_process');
const out = execFileSync('powershell', ['-NoProfile', '-Command',
  "Get-ChildItem 'D:\\uniterm\\kaihongos\\entry' -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $s=0; Get-ChildItem $_.FullName -File -ErrorAction SilentlyContinue | ForEach-Object {$s+=$_.Length}; if($s -gt 10MB){ '{0,10} {1}' -f [math]::Round($s/1MB,1), $_.FullName } }"],
  { encoding: 'utf8' });
console.log(out);
