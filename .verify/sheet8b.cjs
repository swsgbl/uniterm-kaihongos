// crop iter8b into regions and produce small compare sheets (structure-level check, no vision model needed)
const { execFileSync } = require('child_process');
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const EV = 'D:/uniterm/evidence/M5/relay2';
const cur = EV + '/iter8b-start.png';
const ref = 'D:/uniterm/evidence/ui-parity/ref-official.png';
const sh = (a) => { try { console.log(execFileSync(M, a, { encoding: 'utf8' })); } catch (e) { console.log('ERR', e.status, String(e.stderr).slice(0, 200)); } };

// scale ref (1920x1032) and cur (1600x900) to same 1600 width for rough visual compare sheet
sh(['convert', ref, '-resize', '1600x', EV + '/_ref1600.png']);
sh(['convert', cur, EV + '/_cur1600.png']);
sh(['convert', EV + '/_ref1600.png', EV + '/_cur1600.png', '-append', EV + '/cmp-iter8b.png']);
console.log('sheet:', EV + '/cmp-iter8b.png');
