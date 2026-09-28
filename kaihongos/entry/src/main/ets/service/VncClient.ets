// VNC (RFB 3.8) 客户端 — 纯 TS 实现
// 状态机:VERSION(12B) -> SECTYPE(1+N) -> AUTHRESULT(4B) -> CLIENTINIT -> SERVERINIT
// -> 主循环 SetEncodings(raw) -> FBUpdateRequest <-> FramebufferUpdate(raw 矩形)
// 渲染:image.createPixelMapSync + writePixels 增量刷新
import socket from '@ohos.net.socket';
import image from '@ohos.multimedia.image';

export interface VncRect {
  x: number
  y: number
  w: number
  h: number
}

export type VncState = 'idle' | 'version' | 'auth' | 'running' | 'error' | 'closed';

type Phase = 0 | 1 | 2 | 3; // 0=version 1=sectype 2=authresult 3=serverinit

export class VncClient {
  private sock: socket.TCPSocket | null = null;
  private buf: Uint8Array = new Uint8Array(0);
  private fb: Uint8Array = new Uint8Array(0);
  private st: VncState = 'idle';
  private phase: Phase = 0;
  private w: number = 0;
  private h: number = 0;
  private pix: image.PixelMap | null = null;
  private pendingRects: number = -1;
  private rectHdr: VncRect | null = null;
  private encType: number = -1;
  onUpdate: () => void = () => {
  };

  width(): number { return this.w; }
  height(): number { return this.h; }
  status(): VncState { return this.st; }
  pixelMap(): image.PixelMap | null { return this.pix; }

  async connect(host: string, port: number): Promise<void> {
    this.st = 'version';
    const s = socket.constructTCPSocketInstance();
    this.sock = s;
    s.on('message', (info: socket.SocketMessageInfo) => { this.onData(info.message); });
    s.on('close', () => { this.st = 'closed'; });
    s.on('error', () => { this.st = 'error'; });
    await s.connect({ address: { address: host, port: port }, timeout: 10 });
  }

  close(): void {
    if (this.sock !== null) {
      try { this.sock.close(); } catch (e) { }
      this.sock = null;
    }
    this.st = 'closed';
  }

  private onData(chunk: ArrayBuffer): void {
    const c = new Uint8Array(chunk);
    const merged = new Uint8Array(this.buf.length + c.length);
    merged.set(this.buf, 0);
    merged.set(c, this.buf.length);
    this.buf = merged;
    this.pump();
  }

  private take(n: number): Uint8Array {
    const out = this.buf.slice(0, n);
    this.buf = this.buf.slice(n);
    return out;
  }

  private pump(): void {
    let progressed = true;
    while (progressed) {
      progressed = false;
      if (this.phase === 0) { // version
        if (this.buf.length >= 12) {
          this.take(12); // 服务器 "RFB 003.008\n"
          this.send(new Uint8Array([0x52, 0x46, 0x42, 0x20, 0x30, 0x30, 0x33, 0x2e, 0x30, 0x30, 0x38, 0x0a])); // "RFB 003.008\n"
          this.phase = 1;
          progressed = true;
        }
      } else if (this.phase === 1) { // sectype: count(1) [types]
        if (this.buf.length >= 1) {
          const n = this.buf[0];
          if (n === 0) { this.st = 'error'; return; }
          if (this.buf.length >= 1 + n) {
            this.take(1);
            const types = this.take(n);
            // 选 None(1) 优先,否则 VNC Auth(2)
            let pick = 1;
            for (let i = 0; i < types.length; i++) {
              if (types[i] === 1) { pick = 1; break; }
              if (types[i] === 2) { pick = 2; }
            }
            this.send(new Uint8Array([pick]));
            this.phase = 2;
            progressed = true;
          }
        }
      } else if (this.phase === 2) { // auth result(仅 None 类型有;VNC Auth 还需 DES 挑战,此处仅支持 None)
        if (this.buf.length >= 4) {
          const r = this.take(4);
          const ok = (r[0] << 24 | r[1] << 16 | r[2] << 8 | r[3]) === 0;
          if (!ok) { this.st = 'error'; return; }
          this.send(new Uint8Array([1])); // ClientInit shared=1
          this.phase = 3;
          progressed = true;
        }
      } else if (this.phase === 3) { // ServerInit
        if (this.buf.length >= 24) {
          const hdr = this.take(24);
          this.w = (hdr[0] << 8) | hdr[1];
          this.h = (hdr[2] << 8) | hdr[3];
          const nameLen = (hdr[20] << 24) | (hdr[21] << 16) | (hdr[22] << 8) | hdr[23];
          if (this.buf.length >= nameLen) {
            this.take(nameLen);
            this.fb = new Uint8Array(this.w * this.h * 4);
            const opts: image.InitializationOptions = {
              size: { width: this.w, height: this.h },
              pixelFormat: image.PixelMapFormat.RGBA_8888
            };
            this.pix = image.createPixelMapSync(this.fb.buffer, opts);
            this.st = 'running';
            this.phase = 0; // 复用为"主循环"判定:st==='running' 走 update
            this.sendSetEncodings();
            this.requestUpdate(false);
            progressed = true;
          }
        }
      } else if (this.st === 'running') { // 主循环:server -> client 消息
        if (this.buf.length >= 1) {
          const t = this.buf[0];
          if (t === 0) { // FramebufferUpdate
            if (this.buf.length >= 4) {
              this.take(4);
              this.pendingRects = (this.buf[0] << 8) | this.buf[1];
              this.take(2);
              if (this.tryRects()) {
                progressed = true;
              }
            }
          } else if (t === 1) { // SetColourMapEntries
            if (this.buf.length >= 6) {
              this.take(6);
              // 简化:跳过(用固定像素格式请求)
            }
          } else if (t === 2) { // Bell
            this.take(1);
            progressed = true;
          } else if (t === 3) { // ServerCutText
            if (this.buf.length >= 8) {
              const l = ((this.buf[4] << 24) | (this.buf[5] << 16) | (this.buf[6] << 8) | this.buf[7]) >>> 0;
              if (this.buf.length >= 8 + l) {
                this.take(8 + l);
                progressed = true;
              }
            }
          } else {
            this.take(1); // 未知:丢 1 字节防死循环
            progressed = true;
          }
        }
      }
    }
  }

  private tryRects(): boolean {
    while (this.pendingRects > 0) {
      if (this.rectHdr === null) {
        if (this.buf.length < 12) { return false; }
        const b = this.take(12);
        const x = (b[0] << 8) | b[1];
        const y = (b[2] << 8) | b[3];
        const w = (b[4] << 8) | b[5];
        const h = (b[6] << 8) | b[7];
        this.encType = ((b[8] << 24) | (b[9] << 16) | (b[10] << 8) | b[11]) >>> 0;
        this.rectHdr = { x: x, y: y, w: w, h: h };
      }
      const r = this.rectHdr as VncRect;
      if (this.encType === 0) { // raw(服务器按我们的请求走 32bpp)
        const need = r.w * r.h * 4;
        if (this.buf.length < need) { return false; }
        const px = this.take(need);
        this.blitRaw(r, px);
      } else if (this.encType === 1) { // copyrect:4 字节源坐标
        if (this.buf.length < 4) { return false; }
        this.take(4);
        // 简化:忽略内容(要求重绘区域会由后续 raw 补)
      } else { // pseudo-encoding(h264/cursor 等):无载荷,跳过
      }
      this.rectHdr = null;
      this.pendingRects--;
    }
    if (this.pendingRects === 0) {
      this.pendingRects = -1;
      this.onUpdate();
      this.requestUpdate(true);
    }
    return true;
  }

  private blitRaw(r: VncRect, px: Uint8Array): void {
    if (r.x + r.w > this.w || r.y + r.h > this.h) {
      return; // 越界保护
    }
    // 我们请求的是 32bpp little-endian RGB(见 SetPixelFormat,默认 888);小端字节序 = B,G,R,X
    for (let row = 0; row < r.h; row++) {
      const srcBase = row * r.w * 4;
      const dstBase = ((r.y + row) * this.w + r.x) * 4;
      for (let col = 0; col < r.w; col++) {
        const s = srcBase + col * 4;
        const d = dstBase + col * 4;
        const b0 = px[s];      // little-endian 第一字节
        const b1 = px[s + 1];
        const b2 = px[s + 2];
        // 我们 SetPixelFormat true-colour, red-max=255 shift=16 → 服务器发 XXRRGGBB 小端 = BB GG RR XX
        this.fb[d] = b2;       // R
        this.fb[d + 1] = b1;   // G
        this.fb[d + 2] = b0;   // B
        this.fb[d + 3] = 255;  // A
      }
    }
    if (this.pix !== null) {
      const start = ((r.y * this.w) + r.x) * 4;
      const end = (((r.y + r.h - 1) * this.w) + r.x + r.w) * 4;
      const slice = this.fb.slice(start, end);
      const area: image.PositionArea = {
        pixels: slice.buffer,
        offset: 0,
        stride: r.w * 4,
        region: { x: r.x, y: r.y, size: { width: r.w, height: r.h } }
      };
      this.pix.writePixelsSync(area);
    }
  }

  // ===== 发送 =====
  private async send(bytes: Uint8Array): Promise<void> {
    if (this.sock === null) { return; }
    try {
      const ab = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.length);
      await this.sock.send({ data: ab });
    } catch (e) {
    }
  }

  private sendSetPixelFormat(): void {
    const p = new Uint8Array(20);
    p[0] = 0;
    const b = new DataView(p.buffer);
    b.setUint8(4, 32);   // bits-per-pixel
    b.setUint8(5, 24);   // depth
    b.setUint8(6, 0);    // big-endian-flag = 0(小端)
    b.setUint8(7, 1);    // true-colour-flag
    b.setUint16(8, 255); // red-max
    b.setUint16(10, 255); // green-max
    b.setUint16(12, 255); // blue-max
    b.setUint8(16, 16);  // red-shift  (让服务器发 XXRRGGBB)
    b.setUint8(17, 8);   // green-shift
    b.setUint8(18, 0);   // blue-shift
    this.send(p);
  }

  private sendSetEncodings(): void {
    this.sendSetPixelFormat();
    const p = new Uint8Array(12);
    p[0] = 2;
    const b = new DataView(p.buffer);
    b.setUint16(2, 1);
    b.setInt32(4, 0); // raw
    this.send(p);
  }

  requestUpdate(incremental: boolean): void {
    if (this.w === 0) { return; }
    const p = new Uint8Array(10);
    p[0] = 3;
    p[1] = incremental ? 1 : 0;
    const b = new DataView(p.buffer);
    b.setUint16(2, 0);
    b.setUint16(4, 0);
    b.setUint16(6, this.w);
    b.setUint16(8, this.h);
    this.send(p);
  }

  sendKey(key: number, down: boolean): void {
    const p = new Uint8Array(8);
    p[0] = 4;
    p[1] = down ? 1 : 0;
    const b = new DataView(p.buffer);
    b.setUint32(4, key);
    this.send(p);
  }

  sendPointer(x: number, y: number, mask: number): void {
    const p = new Uint8Array(6);
    p[0] = 5;
    p[1] = mask;
    const b = new DataView(p.buffer);
    b.setUint16(2, x);
    b.setUint16(4, y);
    this.send(p);
  }
}
