// scan for residual navy theme list arrays / storage defaults
const fs = require('fs');
const path = require('path');
const ROOT = 'D:/uniterm/kaihongos/entry/src/main/ets';
(function walk(d){ for (const e of fs.readdirSync(d,{withFileTypes:true})) {
  const p = path.join(d,e.name);
  if (e.isDirectory()) walk(p);
  else if (e.name.endsWith('.ets')) {
    const s = fs.readFileSync(p,'utf8');
    s.split('\n').forEach((l,i)=>{
      if (/navy/.test(l)) console.log(p.substring(43)+':'+(i+1)+': '+l.trim().slice(0,100));
      if (/\[\s*'dark'\s*,/.test(l)) console.log('[THEMELIST] '+p.substring(43)+':'+(i+1)+': '+l.trim().slice(0,100));
    });
  }
}})(ROOT);
console.log('SCAN DONE');
