// M6 relay2: remove navy from SettingsTab + SidePanels theme labels
const fs = require('fs');
const targets = [
  'D:/uniterm/kaihongos/entry/src/main/ets/components/SettingsTab.ets',
  'D:/uniterm/kaihongos/entry/src/main/ets/components/SidePanels.ets',
];
for (const f of targets) {
  let s = fs.readFileSync(f, 'utf8');
  s = s.replace("Text(n === 'dark' ? '暗色' : n === 'navy' ? '深蓝' : '浅色')", "Text(n === 'dark' ? '暗色' : '浅色')");
  fs.writeFileSync(f, s);
  console.log(f.split('/').pop(), 'navy residual:', (s.match(/navy|深蓝/g) || []).length);
}
