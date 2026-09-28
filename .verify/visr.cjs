// retry wrapper: glm-4.5v sometimes returns empty content on rate-limit; retry with backoff
const { execFileSync } = require('child_process');
const fs = require('fs');
const src = process.argv[2];
const question = process.argv[3] || 'Describe this screenshot.';
const width = process.argv[4] || '900';
const M = 'C:/Users/hongfu/tools/ImageMagick-7.1.2-Q16-HDRI/magick.exe';
const jpg = execFileSync(M, ['convert', src, '-resize', width + 'x', '-quality', '82', 'jpg:'], { maxBuffer: 64 * 1024 * 1024 });
const b64 = jpg.toString('base64');
const body = JSON.stringify({
  model: 'glm-4.5v',
  messages: [{ role: 'user', content: [
    { type: 'image_url', image_url: { url: 'data:image/jpeg;base64,' + b64 } },
    { type: 'text', text: question },
  ]}],
  max_tokens: 1000, temperature: 0.3,
});
fs.writeFileSync('D:/uniterm/.verify/_vis_body.json', body);
const curl = 'curl -s -S --max-time 120 -X POST "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions" -H "Content-Type: application/json" -H "Authorization: Bearer 123d2ec1d4814ded9317318f78f4dc6d.fOY4eMcB9MowGw3D" --data-binary "@D:/uniterm/.verify/_vis_body.json"';
for (let attempt = 1; attempt <= 4; attempt++) {
  let resp;
  try { resp = execFileSync(curl, { encoding: 'utf8', shell: 'cmd.exe', timeout: 150000, maxBuffer: 64 * 1024 * 1024 }); }
  catch (e) { console.log('attempt', attempt, 'curl-fail', String(e.message).slice(0, 120)); continue; }
  let j; try { j = JSON.parse(resp); } catch (e) { console.log('attempt', attempt, 'parse-fail', resp.slice(0, 200)); continue; }
  if (j.error) { console.log('attempt', attempt, 'API:', JSON.stringify(j.error).slice(0, 150)); execFileSync('powershell', ['-NoProfile', '-Command', 'Start-Sleep -Seconds 20']); continue; }
  const txt = j.choices?.[0]?.message?.content;
  if (typeof txt === 'string' && txt.trim()) { console.log('=== ANSWER ==='); console.log(txt); process.exit(0); }
  console.log('attempt', attempt, 'empty content, finish_reason=', j.choices?.[0]?.finish_reason);
  execFileSync('powershell', ['-NoProfile', '-Command', 'Start-Sleep -Seconds 15']);
}
console.log('ALL ATTEMPTS FAILED');
process.exit(1);
