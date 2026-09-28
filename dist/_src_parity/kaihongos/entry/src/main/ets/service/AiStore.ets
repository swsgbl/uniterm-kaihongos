// AI 会话持久化(filesDir/ai_sessions.json)
import fs from '@ohos.file.fs';

export interface AiMsgRec {
  role: string
  text: string
  ts: number
}

export interface AiSessionRec {
  id: number
  name: string
  msgs: AiMsgRec[]
  updatedAt: number
}

export class AiStore {
  private static path(filesDir: string): string {
    return filesDir + '/ai_sessions.json'
  }

  static async read(filesDir: string): Promise<AiSessionRec[]> {
    const p = AiStore.path(filesDir)
    if (!fs.accessSync(p)) {
      return []
    }
    try {
      const raw = fs.readTextSync(p)
      const obj = JSON.parse(raw) as AiSessionRec[]
      return Array.isArray(obj) ? obj : []
    } catch (e) {
      return []
    }
  }

  static async write(filesDir: string, sessions: AiSessionRec[]): Promise<void> {
    try {
      const p = AiStore.path(filesDir)
      const f = fs.openSync(p, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
      fs.writeSync(f.fd, JSON.stringify(sessions))
      fs.closeSync(f)
    } catch (e) {
    }
  }
}
