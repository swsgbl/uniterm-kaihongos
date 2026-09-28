// find exact window bounds (transition from wallpaper blue to app dark) then crop + internal structure probe
const { execFileSync } = require('child_process');
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const img = 'D:/uniterm/evidence/M5/relay2/iter8b-start.png';
const EV = 'D:/uniterm/evidence/M5/relay2';
function rgb(x, y) {
  const s = execFileSync(M, [img + '[0]', '-format', `%[pixel:p{${x},${y}}]`, 'info:'], { encoding: 'utf8' }).trim();
  const m = s.match(/(\d+),(\d+),(\d+)/);
  return m ? [+m[1], +m[2], +m[3]] : [0, 0, 0];
}
const isDark = (p) => p[0] < 60 && p[1] < 60 && p[2] < 70;
// left/right bounds at y=450
let L = -1, R = -1;
for (let x = 0; x < 1600; x++) { if (isDark(rgb(x, 450))) { L = x; break; } }
for (let x = 1599; x >= 0; x--) { if (isDark(rgb(x, 450))) { R = x; break; } }
// top/bottom bounds at x=(L+R)/2
const cx = Math.floor((L + R) / 2);
let T = -1, B = -1;
for (let y = 0; y < 900; y++) { if (isDark(rgb(cx, y))) { T = y; break; } }
for (let y = 899; y >= 0; y--) { if (isDark(rgb(cx, y))) { B = y; break; } }
console.log('window bounds: L=' + L, 'R=' + R, 'T=' + T, 'B=' + B, ' => ' + (R - L + 1) + 'x' + (B - T + 1));
// crop window
execFileSync(M, ['convert', img, '-crop', `${R - L + 1}x${B - T + 1}+${L}+${T}`, '+repage', EV + '/iter8b-win.png']);
console.log('cropped ->', EV + '/iter8b-win.png');
// internal probe: title strip vs tab strip vs sidebar edge within window
const px = (x, y) => execFileSync(M, [EV + '/iter8b-win.png[0]', '-format', `%[pixel:p{${x},${y}}]`, 'info:'], { encoding: 'utf8' }).trim();
for (const y of [5, 15, 25, 35, 45, 55]) console.log('win col x=200 y=' + y, px(200, y));
for (const x of [180, 220, 260, 280, 300, 320]) console.log('win row y=300 x=' + x, px(x, 300));
