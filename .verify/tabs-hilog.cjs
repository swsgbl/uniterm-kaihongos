const fs = require('fs');
function patch(file, edits) {
  let s = fs.readFileSync(file, 'utf8');
  for (const [old, nw] of edits) {
    if (!s.includes(old)) { console.log('MISS in ' + file + ': ' + old.slice(0, 60).replace(/\n/g, '\\n')); continue; }
    s = s.replace(old, nw);
    console.log('OK   ' + file + ': ' + old.slice(0, 50).replace(/\n/g, '\\n'));
  }
  fs.writeFileSync(file, s, 'utf8');
}

// ============ VncTab.ets ============
patch('D:/uniterm/kaihongos/entry/src/main/ets/components/VncTab.ets', [
  [
    "import { VncClient } from '../service/VncClient';",
    "import { VncClient } from '../service/VncClient';\nimport { hilog } from '@kit.PerformanceAnalysisKit';\n\nconst VNC_TAG: string = 'uniterm.vnc';\nconst VNC_DOMAIN: number = 0x0110;"
  ],
  [
    "    this.st = 'connecting'\n    this.errText = ''",
    "    this.st = 'connecting'\n    this.errText = ''\n    hilog.info(VNC_DOMAIN, VNC_TAG, 'tab connect requested host=%{public}s port=%{public}s', h, this.port);"
  ],
  [
    "      this.st = 'error'\n      this.errText = e.toString().substring(0, 200)",
    "      this.st = 'error'\n      this.errText = e.toString().substring(0, 200)\n      hilog.error(VNC_DOMAIN, VNC_TAG, 'connect failed: %{public}s', e.toString().substring(0, 100));"
  ],
  [
    "      if (s === 'running' && this.st !== 'running') {\n        this.st = 'running'",
    "      if (s === 'running' && this.st !== 'running') {\n        this.st = 'running'\n        hilog.info(VNC_DOMAIN, VNC_TAG, 'session running, frames=%{public}d', this.frameTick);"
  ],
]);

// ============ RdpTab.ets ============
patch('D:/uniterm/kaihongos/entry/src/main/ets/components/RdpTab.ets', [
  [
    "import { RdpNapi } from 'librdpproxy.so';\nimport image from '@ohos.multimedia.image';",
    "import { RdpNapi } from 'librdpproxy.so';\nimport image from '@ohos.multimedia.image';\nimport { hilog } from '@kit.PerformanceAnalysisKit';\n\nconst RDP_TAG: string = 'uniterm.rdp';\nconst RDP_DOMAIN: number = 0x0110;"
  ],
  [
    "    this.errText = ''\n    try {",
    "    this.errText = ''\n    hilog.info(RDP_DOMAIN, RDP_TAG, 'rdp connect begin host=%{public}s port=%{public}s user=%{public}s', h, this.port, this.user);\n    try {"
  ],
  [
    "    } catch (e) {\n      this.connected = false\n      this.errText = 'rdpproxy 加载失败: ' + JSON.stringify(e).substring(0, 200)\n    }",
    "    } catch (e) {\n      this.connected = false\n      this.errText = 'rdpproxy 加载失败: ' + JSON.stringify(e).substring(0, 200)\n      hilog.error(RDP_DOMAIN, RDP_TAG, 'rdp connect failed: %{public}s', JSON.stringify(e).substring(0, 200));\n    }"
  ],
  [
    "    // 贴矩形\n    for (let r = 0; r < h; r++) {",
    "    // 贴矩形(首帧/尺寸变化打日志)\n    if (this.fb === null) {\n      hilog.info(RDP_DOMAIN, RDP_TAG, 'first frame delivered w=%{public}d h=%{public}d', this.fbW, this.fbH);\n    }\n    for (let r = 0; r < h; r++) {"
  ],
  [
    "  disconnect(): void {\n    if (this.mod !== null) {\n      this.mod.rdpDisconnect()\n    }\n    this.connected = false",
    "  disconnect(): void {\n    if (this.mod !== null) {\n      this.mod.rdpDisconnect()\n      hilog.info(RDP_DOMAIN, RDP_TAG, 'rdp disconnected');\n    }\n    this.connected = false"
  ],
]);
