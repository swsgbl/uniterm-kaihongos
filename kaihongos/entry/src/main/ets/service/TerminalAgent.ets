// AI 终端 Agent:官方 terminalAgent 复刻(简化单轮回路)
// 回路:LLM → ```bash 代码块 → 按 mode 确认 → SessionService.write → 读 TermModel 屏幕 → 续聊
import { Llm, LlmConfig, LlmMsg } from './Llm';
import { LlmConfigStore } from './LlmConfigStore';
import { SessionService } from './SessionService';

export type AgentMode = 'bypass' | 'confirm_dangerous' | 'confirm_write' | 'confirm_all';

export interface AgentEvent {
  kind: string // 'cmd' | 'out' | 'err' | 'done' | 'need_confirm'
  text: string
}

export class TerminalAgent {
  static mode: AgentMode = 'confirm_dangerous'
  static onEvent: (e: AgentEvent) => void = (e: AgentEvent) => {
  }
  private static pendingCmd: string = ''
  private static busy: boolean = false

  static extractBash(reply: string): string {
    // 提取 ```bash ... ``` 或 ```sh ... ``` 代码块;无块时取全文首行(以 $ 开头剥离)
    const re = /```(?:bash|sh|shell)\n([\s\S]*?)```/
    const m = re.exec(reply)
    if (m !== null && m !== undefined && m.length > 1) {
      return m[1].trim()
    }
    const plain = /```(?:bash|sh|shell)\s+([^\n`]+)/
    const m2 = plain.exec(reply)
    if (m2 !== null && m2 !== undefined && m2.length > 1) {
      return m2[1].trim()
    }
    return ''
  }

  static riskOf(cmd: string): string {
    // 粗分级:写操作/删除/包管理/重启 → dangerous;状态查看 → read;其余 → write
    const d = /rm\s|mkfs|dd\s|reboot|shutdown|kill|chmod|chown|>\s*\/|curl.*\|\s*sh|wget.*\|\s*sh/
    if (d.test(cmd)) {
      return 'dangerous'
    }
    const r = /^(ls|cat|pwd|whoami|uname|df|free|ps|ip|ifconfig|netstat|uptime|top|head|tail|grep|echo|date|id)\b/
    if (r.test(cmd)) {
      return 'read'
    }
    return 'write'
  }

  static needConfirm(risk: string): boolean {
    // 官方 agent.ts shouldConfirm 同构
    if (TerminalAgent.mode === 'confirm_all') {
      return true
    }
    if (TerminalAgent.mode === 'confirm_write') {
      return risk !== 'read'
    }
    if (TerminalAgent.mode === 'confirm_dangerous') {
      return risk === 'dangerous'
    }
    return false // bypass
  }

  /** 单轮回路:用户指令 → 模型 → 命令 → (确认) → 执行 → 输出回模型总结 → 回调 */
  static async run(userText: string, screenSnapshot: string): Promise<void> {
    if (TerminalAgent.busy) {
      return
    }
    TerminalAgent.busy = true
    try {
      const filesDir = TerminalAgent.getFilesDir()
      const cfg: LlmConfig = LlmConfigStore.read(filesDir)
      if (cfg.apiKey === '') {
        TerminalAgent.onEvent({ kind: 'err', text: '未配置模型(设置→AI 模型)' })
        return
      }
      if (!SessionService.hasSession()) {
        TerminalAgent.onEvent({ kind: 'err', text: '无活动终端会话' })
        return
      }
      const sys = '你是终端 AI 助理。用户描述需求,你输出一条可直接执行的 shell 命令,' +
        '用 ```bash 代码块包裹,不要解释。当前终端屏幕内容:\n' + screenSnapshot.substring(0, 2000)
      const hist: LlmMsg[] = [{ role: 'user', text: userText } as LlmMsg]
      const reply = await Llm.chat(cfg, hist, sys)
      const cmd = TerminalAgent.extractBash(reply)
      if (cmd === '') {
        TerminalAgent.onEvent({ kind: 'done', text: reply })
        return
      }
      const risk = TerminalAgent.riskOf(cmd)
      if (TerminalAgent.needConfirm(risk)) {
        TerminalAgent.pendingCmd = cmd
        TerminalAgent.onEvent({ kind: 'need_confirm', text: cmd })
        return
      }
      await TerminalAgent.exec(cmd, reply)
    } finally {
      TerminalAgent.busy = false
    }
  }

  /** 用户点了"允许"后调用 */
  static async approve(): Promise<void> {
    const cmd = TerminalAgent.pendingCmd
    TerminalAgent.pendingCmd = ''
    if (cmd !== '') {
      TerminalAgent.busy = false
      await TerminalAgent.exec(cmd, '')
    }
  }

  static deny(): void {
    TerminalAgent.pendingCmd = ''
    TerminalAgent.onEvent({ kind: 'done', text: '(已拒绝执行)' })
  }

  private static async exec(cmd: string, firstReply: string): Promise<void> {
    TerminalAgent.onEvent({ kind: 'cmd', text: cmd })
    SessionService.write(cmd + '\n')
    // 等命令输出(简化:固定 2.5s 后截屏)
    await TerminalAgent.sleep(2500)
    const out = SessionService.screenText(2000)
    TerminalAgent.onEvent({ kind: 'out', text: out })
    // 让模型总结结果
    try {
      const filesDir = TerminalAgent.getFilesDir()
      const cfg = LlmConfigStore.read(filesDir)
      const hist: LlmMsg[] = [
        { role: 'user', text: '执行: ' + cmd } as LlmMsg,
        { role: 'assistant', text: firstReply !== '' ? firstReply : '```bash\n' + cmd + '\n```' } as LlmMsg,
        { role: 'user', text: '命令已执行,终端输出:\n' + out } as LlmMsg
      ]
      const sum = await Llm.chat(cfg, hist, '总结命令执行结果,简洁中文,两三句话。')
      TerminalAgent.onEvent({ kind: 'done', text: sum })
    } catch (e) {
      TerminalAgent.onEvent({ kind: 'done', text: out })
    }
  }

  private static sleep(ms: number): Promise<void> {
    return new Promise<void>(resolve => setTimeout(resolve, ms))
  }

  private static getFilesDir(): string {
    return AppStorage.get<string>('ut.filesDir') ?? ''
  }
}
