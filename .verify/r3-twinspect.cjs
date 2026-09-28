const fs = require('fs');
const f = process.argv[2];
const data = fs.readFileSync(f, 'utf8');
const lines = data.split(/\r?\n/);
// dump all run_command invocations + user/assistant text containing start/quickemu/vnc
for (let i = 0; i < lines.length; i++) {
  let o; try { o = JSON.parse(lines[i]); } catch (e) { continue; }
  if (o.t !== 'assistant' || !o.tool_calls) continue;
  for (const c of o.tool_calls) {
    if (!c.function) continue;
    let arg; try { arg = JSON.parse(c.function.arguments); } catch (e) { continue; }
    const body = String(arg.command || arg.content || arg.path || '');
    if (/quickemu|qemu|vnc|15566|5905/i.test(body) && c.function.name !== 'read_file') {
      console.log('L' + i + ' [' + c.function.name + '] ' + body.slice(0, 900).replace(/\n/g, ' | '));
      console.log('');
    }
  }
}
