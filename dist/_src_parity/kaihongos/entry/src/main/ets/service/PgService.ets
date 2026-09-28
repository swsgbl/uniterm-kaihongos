// PostgreSQL 客户端:wire 协议 v3 纯 TS(@ohos.net.socket + cryptoFramework MD5)
// 子集:startup / cleartext+md5 认证(scram 提示不支持) / 简单查询 Q+T/D/C/E/Z
import socket from '@ohos.net.socket';
import cryptoFramework from '@ohos.security.cryptoFramework';

export class PgService {
  private static sock: socket.TCPSocket | null = null
  private static pending: number[] = []

  static active(): boolean {
    return PgService.sock !== null
  }

  static async connect(host: string, port: number, user: string, password: string, db: string): Promise<void> {
    if (PgService.sock !== null) {
      await PgService.close()
    }
    const s = socket.constructTCPSocketInstance()
    s.on('message', (info: socket.SocketMessageInfo) => {
      const u8 = new Uint8Array(info.message)
      for (let i = 0; i < u8.length; i++) {
        PgService.pending.push(u8[i])
      }
    })
    await s.connect({ address: { address: host, port: port }, timeout: 10 })
    PgService.sock = s
    // StartupMessage(无类型字节): len + 196608 + "user\0u\0database\0d\0\0"
    const params = 'user\0' + user + '\0database\0' + db + '\0\0'
    const body = new Uint8Array(4 + 4 + params.length)
    PgService.putInt32(body, 0, 8 + params.length)
    PgService.putInt32(body, 4, 196608)
    for (let i = 0; i < params.length; i++) {
      body[8 + i] = params.charCodeAt(i) & 0xff
    }
    PgService.pending = []
    await s.send({ data: body.buffer })
    // 认证循环直到 ReadyForQuery('Z')/ErrorResponse('E')
    for (;;) {
      const t = await PgService.waitMsg()
      if (t === 'R') {
        const code = PgService.readI32()
        if (code === 0) {
          continue // AuthenticationOk
        }
        if (code === 3) {
          await PgService.sendPassword(password)
          continue
        }
        if (code === 5) {
          const salt = PgService.readBytes(4)
          const inner = await PgService.md5hex(PgService.strBytes(password + user))
          const salted = PgService.concat(inner.bytes, salt)
          const outer = await PgService.md5hex(salted)
          await PgService.sendPassword('md5' + outer.hex)
          continue
        }
        if (code === 10) {
          throw new Error('服务器要求 SCRAM-SHA-256 认证,请在 pg_hba.conf 改用 md5 或 password')
        }
        throw new Error('不支持的认证方式 code=' + code.toString())
      }
      if (t === 'E') {
        throw new Error(PgService.parseError())
      }
      if (t === 'Z') {
        PgService.readI32()
        PgService.readByte() // tx status
        return
      }
      // S/K 等其余消息跳过
    }
  }

  /** 简单查询:渲染 T/D/C 为文本 */
  static async query(sql: string): Promise<string> {
    const s = PgService.sock
    if (s === null) {
      throw new Error('未连接')
    }
    const payload = sql + '\0'
    const msg = new Uint8Array(5 + payload.length)
    msg[0] = 0x51 // 'Q'
    PgService.putInt32(msg, 1, 4 + payload.length)
    for (let i = 0; i < payload.length; i++) {
      msg[5 + i] = payload.charCodeAt(i) & 0xff
    }
    PgService.pending = []
    await s.send({ data: msg.buffer })
    const lines: string[] = []
    for (;;) {
      const t = await PgService.waitMsg()
      if (t === 'T') {
        PgService.readI32() // len
        const n = PgService.readI16()
        const cols: string[] = []
        for (let i = 0; i < n; i++) {
          cols.push(PgService.readCStr())
          PgService.readBytes(18) // 表oid/attnum/typeoid/typlen/typmod/format
        }
        lines.push(cols.join(' | '))
      } else if (t === 'D') {
        PgService.readI32()
        const n = PgService.readI16()
        const vals: string[] = []
        for (let i = 0; i < n; i++) {
          const flen = PgService.readI32()
          if (flen < 0) {
            vals.push('NULL')
          } else {
            vals.push(PgService.bytesStr(PgService.readBytes(flen)))
          }
        }
        lines.push(vals.join(' | '))
      } else if (t === 'C') {
        PgService.readI32()
        lines.push('(' + PgService.readCStr() + ')')
      } else if (t === 'E') {
        throw new Error(PgService.parseError())
      } else if (t === 'Z') {
        PgService.readI32()
        PgService.readByte()
        return lines.join('\n')
      }
    }
  }

  static async close(): Promise<void> {
    const s = PgService.sock
    PgService.sock = null
    if (s !== null) {
      try {
        s.close()
      } catch (e) {
      }
    }
  }

  // ===== 底层:帧等待/读写 =====
  private static async waitMsg(): Promise<string> {
    for (let i = 0; i < 100; i++) {
      if (PgService.pending.length >= 5) {
        const len = (PgService.pending[1] << 24 | PgService.pending[2] << 16 | PgService.pending[3] << 8 | PgService.pending[4]) >>> 0
        if (PgService.pending.length >= 1 + len) {
          const t = PgService.pending.shift()
          PgService.readI32() // 消费长度
          return t !== undefined ? String.fromCharCode(t) : ''
        }
      }
      await PgService.sleep(30)
    }
    throw new Error('超时等待服务器响应')
  }

  private static readByte(): number {
    const b = PgService.pending.shift()
    return b !== undefined ? b : 0
  }

  private static readI32(): number {
    return ((PgService.readByte() << 24 | PgService.readByte() << 16 | PgService.readByte() << 8 | PgService.readByte()) >>> 0)
  }

  private static readI16(): number {
    return PgService.readByte() << 8 | PgService.readByte()
  }

  private static readBytes(n: number): Uint8Array {
    const out = new Uint8Array(n)
    for (let i = 0; i < n; i++) {
      out[i] = PgService.readByte()
    }
    return out
  }

  private static readCStr(): string {
    let s = ''
    for (;;) {
      const b = PgService.readByte()
      if (b === 0) {
        return s
      }
      s += String.fromCharCode(b)
    }
  }

  private static bytesStr(b: Uint8Array): string {
    let s = ''
    for (let i = 0; i < b.length; i++) {
      s += String.fromCharCode(b[i])
    }
    return s
  }

  private static strBytes(s: string): Uint8Array {
    const out = new Uint8Array(s.length)
    for (let i = 0; i < s.length; i++) {
      out[i] = s.charCodeAt(i) & 0xff
    }
    return out
  }

  private static putInt32(b: Uint8Array, off: number, v: number): void {
    b[off] = (v >>> 24) & 0xff
    b[off + 1] = (v >>> 16) & 0xff
    b[off + 2] = (v >>> 8) & 0xff
    b[off + 3] = v & 0xff
  }

  private static concat(a: Uint8Array, b: Uint8Array): Uint8Array {
    const out = new Uint8Array(a.length + b.length)
    out.set(a, 0)
    out.set(b, a.length)
    return out
  }

  private static async sendPassword(pw: string): Promise<void> {
    const s = PgService.sock
    if (s === null) {
      throw new Error('未连接')
    }
    const payload = pw + '\0'
    const msg = new Uint8Array(5 + payload.length)
    msg[0] = 0x70 // 'p'
    PgService.putInt32(msg, 1, 4 + payload.length)
    for (let i = 0; i < payload.length; i++) {
      msg[5 + i] = payload.charCodeAt(i) & 0xff
    }
    await s.send({ data: msg.buffer })
  }

  private static parseError(): string {
    PgService.readI32()
    let msg = ''
    for (;;) {
      const code = PgService.readByte()
      if (code === 0) {
        break
      }
      const v = PgService.readCStr()
      if (code === 77) { // 'M' message
        msg = v
      }
    }
    return 'ERROR: ' + msg
  }

  private static async md5hex(data: Uint8Array): Promise<HexOut> {
    const md = cryptoFramework.createMd('MD5')
    const blob: cryptoFramework.DataBlob = { data: data }
    await md.update(blob)
    const out = await md.digest()
    const u = out.data
    let hex = ''
    for (let i = 0; i < u.length; i++) {
      hex += (u[i] < 16 ? '0' : '') + u[i].toString(16)
    }
    const r = new HexOut()
    r.hex = hex
    r.bytes = u
    return r
  }

  private static sleep(ms: number): Promise<void> {
    return new Promise<void>(resolve => setTimeout(resolve, ms))
  }
}

class HexOut {
  hex: string = ''
  bytes: Uint8Array = new Uint8Array(0)
}
