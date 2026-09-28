// scan vertical + horizontal color profile to find window bounds
const { execFileSync } = require('child_process');
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const img = process.argv[2];
function px(x, y) {
  try { return execFileSync(M, [img + '[0]', '-format', `%[pixel:p{${x},${y}}]`, 'info:'], { encoding: 'utf8' }).trim(); } catch (e) { return 'ERR'; }
}
console.log('== vertical scan x=800 ==');
for (let y = 0; y <= 880; y += 40) console.log('y=' + y, px(800, y));
console.log('== horizontal scan y=450 ==');
for (let x = 0; x <= 1560; x += 80) console.log('x=' + x, px(x, 450));
console.log('== horizontal scan y=100 ==');
for (let x = 0; x <= 1560; x += 80) console.log('x=' + x, px(x, 100));
