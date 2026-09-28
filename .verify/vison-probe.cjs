// probe the glm-vision endpoint directly with a small image
const fs = require('fs');
(async () => {
  const cfg = JSON.parse(fs.readFileSync('C:/Users/hongfu/.hmharness/config.json', 'utf8'));
  const v = cfg.providers['glm-vision'];
  const b = fs.readFileSync('D:/uniterm/evidence/M5/relay2/ref/side-tree.png');
  console.log('img bytes', b.length);
  const body = JSON.stringify({
    model: v.model,
    messages: [{ role: 'user', content: [
      { type: 'image_url', image_url: { url: 'data:image/png;base64,' + b.toString('base64') } },
      { type: 'text', text: '这是终端应用的左侧栏。按从上到下顺序列出元素,并描述连接行的结构。' }
    ] }],
    max_tokens: 300
  });
  const ctl = new AbortController();
  const to = setTimeout(() => ctl.abort(), 60000);
  try {
    const r = await fetch(v.baseUrl + '/chat/completions', { method: 'POST', headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + v.apiKey }, body, signal: ctl.signal });
    console.log('status', r.status);
    const t = await r.text();
    console.log(t.slice(0, 1200));
  } catch (e) { console.log('ERR', e.message); }
  clearTimeout(to);
})();
