const fs = require('fs');
const p = 'D:/uniterm/kaihongos/entry/src/main/ets/service/VncClient.ets';
let s = fs.readFileSync(p, 'utf8');
const lines = s.split('\n');
// find the line containing "this.phase = 1;" right after the version send line
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('this.send(new Uint8Array([0x52') && lines[i].includes('0x0a]')) {
    lines[i + 1] = lines[i + 1].replace(
      'this.phase = 1;',
      "hilog.info(VNC_DOMAIN, VNC_TAG, 'version handshake RFB 003.008');\n          this.phase = 1;"
    );
    console.log('inserted before line', i + 2);
    break;
  }
}
fs.writeFileSync(p, lines.join('\n'), 'utf8');
console.log('done');
