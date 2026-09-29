const fs = require('fs');
const p = 'D:/uniterm/kaihongos/entry/src/main/ets/service/VncClient.ets';
let s = fs.readFileSync(p, 'utf8');
let n = 0;

function rep(old, nw) {
  global.n++;
  if (!s.includes(old)) { console.log('MISS #' + n + ': ' + old.slice(0, 60).replace(/\n/g, '\\n')); return; }
  s = s.replace(old, nw);
  console.log('OK   #' + n + ': ' + old.slice(0, 50).replace(/\n/g, '\\n'));
}

// 1. sectype selection log
rep(
  "            this.send(new Uint8Array([pick]));\n            this.phase = 2;\n            progressed = true;",
  "            hilog.info(VNC_DOMAIN, VNC_TAG, 'security type selected=%{public}d offered=%{public}d', pick, n);\n            this.send(new Uint8Array([pick]));\n            this.phase = 2;\n            progressed = true;"
);

// 2. sectype zero error
rep(
  "if (n === 0) { this.st = 'error'; return; }",
  "if (n === 0) { this.st = 'error'; hilog.error(VNC_DOMAIN, VNC_TAG, 'no acceptable security type from server'); return; }"
);

// 3. auth result failure
rep(
  "if (!ok) { this.st = 'error'; return; }\n          this.send(new Uint8Array([1])); // ClientInit shared=1",
  "if (!ok) { this.st = 'error'; hilog.error(VNC_DOMAIN, VNC_TAG, 'auth result failed code=%{public}d', (r[0] << 24 | r[1] << 16 | r[2] << 8 | r[3]) >>> 0); return; }\n          this.send(new Uint8Array([1])); // ClientInit shared=1"
);

// 4. version handshake log
rep(
  "this.send(new Uint8Array([0x52, 0x46, 0x42, 0x20, 0x30, 0x30, 0x2e, 0x30, 0x30, 0x38, 0x0a])); // \"RFB 003.008\\n\"\n          this.phase = 1;",
  "this.send(new Uint8Array([0x52, 0x46, 0x42, 0x20, 0x30, 0x30, 0x2e, 0x30, 0x30, 0x38, 0x0a])); // \"RFB 003.008\\n\"\n          hilog.info(VNC_DOMAIN, VNC_TAG, 'version handshake RFB 003.008');\n          this.phase = 1;"
);

// 5. serverinit log
rep(
  "this.pix = image.createPixelMapSync(this.fb.buffer, opts);\n            this.st = 'running';",
  "this.pix = image.createPixelMapSync(this.fb.buffer, opts);\n            hilog.info(VNC_DOMAIN, VNC_TAG, 'serverinit w=%{public}d h=%{public}d nameLen=%{public}d', this.w, this.h, nameLen);\n            this.st = 'running';"
);

// 6. frame counter
const oldFrame = "    if (this.pendingRects === 0) {\n      this.pendingRects = -1;\n      this.onUpdate();\n      this.requestUpdate(true);\n    }\n    return true;\n  }";
rep(
  oldFrame,
  "    if (this.pendingRects === 0) {\n      this.pendingRects = -1;\n      this.frameCount++;\n      if (this.frameCount <= 5 || this.frameCount % 100 === 0) {\n        hilog.info(VNC_DOMAIN, VNC_TAG, 'frame count=%{public}d rects batch done', this.frameCount);\n      }\n      this.onUpdate();\n      this.requestUpdate(true);\n    }\n    return true;\n  }"
);

// add frameCount field
rep(
  "private encType: number = -1;\n  onUpdate: () => void = () => {",
  "private encType: number = -1;\n  private frameCount: number = 0;\n  onUpdate: () => void = () => {"
);

// 7. close log
rep(
  "  close(): void {\n    if (this.sock !== null) {\n      try { this.sock.close(); } catch (e) { }\n      this.sock = null;\n    }\n    this.st = 'closed';\n  }",
  "  close(): void {\n    if (this.sock !== null) {\n      try { this.sock.close(); } catch (e) { }\n      this.sock = null;\n    }\n    this.st = 'closed';\n    hilog.info(VNC_DOMAIN, VNC_TAG, 'client closed');\n  }"
);

fs.writeFileSync(p, s, 'utf8');
console.log('TOTAL ' + n + ' edits, misses above if any');
