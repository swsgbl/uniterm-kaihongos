// M6 relay2 batch2: UniTheme -> AppTheme rename + field renames + navy removal
const fs = require('fs');
const path = require('path');
const ROOT = 'D:/uniterm/kaihongos/entry/src/main/ets';

// field renames (order matters: longest first to avoid partial overlaps)
const fieldMap = {
  'bgElevated': 'surfaceRaised',
  'bgBase': 'surface',
  'bgSurface': 'panel',
  'bgOverlay': 'hover',
  'textPrimary': 'ink',
  'textSecondary': 'inkSubtle',
  'accent': 'brand',
  'border': 'hairline',
};

const files = [];
(function walk(d){ for (const e of fs.readdirSync(d,{withFileTypes:true})) {
  if (e.isDirectory()) walk(path.join(d,e.name)); else if (e.name.endsWith('.ets')) files.push(path.join(d,e.name));
}})(ROOT);

let totalChanges = 0;
for (const f of files) {
  if (f.endsWith('AppTheme.ets')) continue; // new file already correct
  let s = fs.readFileSync(f,'utf8');
  const before = s;
  // class name + import path
  s = s.split('UniTheme').join('AppTheme');
  s = s.split('common/UniTheme').join('common/AppTheme');
  // field renames via property access patterns: .bgBase / this.bgBase etc -> word boundary
  for (const [oldName, newName] of Object.entries(fieldMap)) {
    const re = new RegExp('\\b' + oldName + '\\b', 'g');
    s = s.replace(re, newName);
  }
  // navy removal: theme option 'navy' + THEME_NAVY references
  s = s.replace(/['"]navy['"]\s*,\s*/g, '');           // "navy", in arrays
  s = s.replace(/,\s*['"]navy['"]/g, '');               // , "navy" in arrays
  s = s.replace(/if \(name === 'navy'\) \{\s*return THEME_NAVY\s*\}\s*/g, '');
  s = s.replace(/THEME_NAVY/g, 'THEME_DARK');           // any residual ref
  if (s !== before) {
    fs.writeFileSync(f,s);
    const n = before.length === s.length ? '(same-len)' : '';
    console.log(path.basename(f), 'updated', n);
    totalChanges++;
  }
}
// remove old UniTheme.ets
const old = path.join(ROOT, 'common/UniTheme.ets');
if (fs.existsSync(old)) { fs.unlinkSync(old); console.log('deleted UniTheme.ets'); }
console.log('FILES CHANGED:', totalChanges);
