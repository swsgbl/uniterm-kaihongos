// direct glm-4.5v vision call with proper jpeg data URL
const { execFileSync } = require('child_process');
const fs = require('fs');
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const src = process.argv[2];
const question = process.argv[3] || 'Describe this screenshot.';
const width = process.argv[4] || '1024';
const jpg = execFileSync(M, ['convert', src, '-resize', width + 'x', '-quality', '85', 'jpg:'], { maxBuffer: 64 * 1024 * 1024 });
const b64 = jpg.toString('base64');
console.error('jpeg bytes:', jpg.length, 'b64 len:', b64.length);
const body = JSON.stringify({
  model: 'glm-4.5v',
  messages: [{
    role: 'user',
    content: [
      { type: 'image_url', image_url: { url: 'data:image/jpeg;base64,' + b64 } },
      { type: 'text', text: question },
    ],
  }],
  max_tokens: 1200,
});
fs.writeFileSync('D:/uniterm/.verify/_vis_body.json', body);
const cmd = 'curl -s -S --max-time 120 -X POST "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions" -H "Content-Type: application/json" -H "Authorization: Bearer 123d2ec1d4814ded9317318f78f4dc6d.fOY4eMcB9MowGw3D" --data-binary "@D:/uniterm/.verify/_vis_body.json"';
try {
  const resp = execFileSync('curl', cmd.split(' ').slice(0, 0).concat([cmd]).length ? [] : [], { shell: 'cmd.exe' }) || '';
} catch (e) { /* unused path */ }
const resp = execFileSync('curl ' + [
  '-s -S --max-time 120 -X POST',
  '"https://open.bigmodel.cn/api/coding/paas/v4/chat/completions"',
  '-H "Content-Type: application/json"',
  '-H "Authorization: Bearer 123d2ec1d4814ded9317318f78f4dc6d.fOY4eMcB9MowGw3D"',
  '--data-binary "@D:/uniterm/.verify/_vis_body.json"',
].join(' '), { encoding: 'utf8', shell: 'cmd.exe', timeout: 150000, maxBuffer: 64 * 1024 * 1024 });
const j = JSON.parse(resp);
if (j.error) { console.log('API ERROR:', JSON.stringify(j.error)); process.exit(1); }
const txt = j.choices && j.choices[0] && j.choices[0].message && j.choices[0].message.content;
console.log('=== VISION ANSWER ===');
console.log(typeof txt === 'string' ? txt : JSON.stringify(txt));
