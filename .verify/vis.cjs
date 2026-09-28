// vision compare: send side-by-side image, ask for diff list (glm-4.5v works, needs big max_tokens)
const fs = require('fs');
(async () => {
  const cfg = JSON.parse(fs.readFileSync('C:/Users/hongfu/.hmharness/config.json', 'utf8'));
  const v = cfg.providers['glm-vision'];
  const p = process.argv[2];
  const q = process.argv[3] || '详细描述这张图。';
  const b = fs.readFileSync(p);
  const body = JSON.stringify({
    model: v.model,
    messages: [{ role: 'user', content: [
      { type: 'image_url', image_url: { url: 'data:image/png;base64,' + b.toString('base64') } },
      { type: 'text', text: q }
    ] }],
    max_tokens: 3000, temperature: 0.2, thinking: { type: 'disabled' }
  });
  const ctl = new AbortController();
  const to = setTimeout(() => ctl.abort(), 110000);
  const t0 = Date.now();
  try {
    const r = await fetch(v.baseUrl + '/chat/completions', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + v.apiKey }, body, signal: ctl.signal });
    const t = await r.text();
    try {
      const j = JSON.parse(t);
      const m = j.choices && j.choices[0] && j.choices[0].message || {};
      console.log('--- finish:', j.choices && j.choices[0].finish_reason, ' usage:', JSON.stringify(j.usage), ' ms:', Date.now() - t0);
      if (m.content) console.log(m.content);
      else console.log('[no content; reasoning head]', (m.reasoning_content || '').slice(0, 300));
    } catch (e) { console.log('status', r.status, t.slice(0, 800)); }
  } catch (e) { console.log('ERR', e.message); }
  clearTimeout(to);
})();
