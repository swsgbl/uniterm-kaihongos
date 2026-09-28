// crop top(ref) and bottom(cur) halves separately and probe each
const { execFileSync } = require('child_process');
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const EV = 'D:/uniterm/evidence/M5/relay2';
execFileSync(M, ['convert', EV + '/_ref1600.png', '-resize', '800x', EV + '/_ref800.jpg']);
execFileSync(M, ['convert', EV + '/_cur1600.png', '-resize', '800x', EV + '/_cur800.jpg']);
console.log('ok');
