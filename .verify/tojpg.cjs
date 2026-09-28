// convert png to base64 jpeg (quality 85, downscale) and call glm-4.5v directly
const { execFileSync } = require('child_process');
const fs = require('fs');
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const src = process.argv[2];
const q = process.argv[3] || '85';
const w = process.argv[4] || '1024';
execFileSync(M, ['convert', src, '-resize', w + 'x', '-quality', q, 'jpg:-'], { stdio: ['ignore', 'pipe', 'ignore'] });
