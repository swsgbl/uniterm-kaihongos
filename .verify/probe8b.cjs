// pixel probe: key regions of iter8b vs official ref baseline colors
const { execFileSync } = require('child_process');
const MAGICK = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const img = process.argv[2];
function px(x, y) {
  try {
    return execFileSync(MAGICK, ['convert', img, '-format', `%[pixel:p{${x},${y}}]`, 'info:'], { encoding: 'utf8' }).trim();
  } catch (e) { return 'ERR'; }
}
const size = execFileSync(MAGICK, ['identify', '-format', '%wx%h', img], { encoding: 'utf8' }).trim();
console.log('img:', img, size);
console.log('top-strip y=19   :', px(800, 19));   // expect near #1b212b header
console.log('sidebar  x=140,y=300:', px(140, 300)); // expect #15191f-ish sidebar
console.log('main    x=800,y=300:', px(800, 300)); // main area
console.log('main    x=800,y=600:', px(800, 600));
console.log('bottom-right      :', px(1400, 850));
