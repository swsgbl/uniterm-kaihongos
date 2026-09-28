// 官方 AISidebar 复刻(结构:ai-header 标题+新建/历史/搜索/最大化/关闭 | ai-messages | ai-input 输入区)
// AI 后端(Anthropic/OpenAI 协议)按官方路线后续接入;先落地一比一布局与本地会话管理
import { common } from '@kit.AbilityKit';
import { AiStore } from '../service/AiStore';
import { Llm, LlmMsg } from '../service/Llm';
import { LlmConfigStore } from '../service/LlmConfigStore';
import { TerminalAgent, AgentEvent } from '../service/TerminalAgent';

interface AiMsg {
  role: string // 'user' | 'assistant'
  text: string
  ts: number
}

interface AiSession {
  id: number
  name: string
  msgs: AiMsg[]
  updatedAt: number
}

@Component
export struct AISidebar {
  @Link visible: boolean
  @State msgs: AiMsg[] = []
  @State sessions: AiSession[] = []
  @State curSession: number = -1
  @State input: string = ''
  @State title: string = 'AI 助理'
  @State busy: boolean = false
  @State cfgVisible: boolean = false
  @State agentMode: boolean = false // 终端执行模式(官方 AI Agent)
  @State confirmCmd: string = ''
  @State cfgProvider: string = 'anthropic'
  @State cfgBaseUrl: string = 'https://api.anthropic.com'
  @State cfgApiKey: string = ''
  @State cfgModel: string = 'claude-sonnet-4-5'
  private filesDir: string = ''
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    this.filesDir = ctx.filesDir
    const cfg = LlmConfigStore.read(this.filesDir)
    this.cfgProvider = cfg.provider
    this.cfgBaseUrl = cfg.baseUrl
    this.cfgApiKey = cfg.apiKey
    this.cfgModel = cfg.model
    this.readSessions()
  }

  saveCfg(): void {
    LlmConfigStore.write(this.filesDir, {
      provider: this.cfgProvider,
      baseUrl: this.cfgBaseUrl,
      apiKey: this.cfgApiKey,
      model: this.cfgModel
    })
    this.cfgVisible = false
  }

  // ===== 会话持久化(ai_sessions.json) =====
  readSessions(): void {
    AiStore.read(this.filesDir).then((ss: AiSession[]) => {
      this.sessions = ss
      if (ss.length > 0) {
        this.curSession = ss[0].id
        this.msgs = ss[0].msgs
      }
    })
  }

  newSession(): void {
    const s: AiSession = { id: Date.now(), name: '新会话', msgs: [], updatedAt: Date.now() }
    this.sessions.unshift(s)
    this.curSession = s.id
    this.msgs = []
    this.persist()
  }

  selectSession(id: number): void {
    const s = this.sessions.find(x => x.id === id)
    if (s !== undefined) {
      this.curSession = id
      this.msgs = s.msgs
    }
  }

  deleteSession(id: number): void {
    const idx = this.sessions.findIndex(x => x.id === id)
    if (idx >= 0) {
      this.sessions.splice(idx, 1)
      if (this.curSession === id) {
        if (this.sessions.length > 0) {
          this.selectSession(this.sessions[0].id)
        } else {
          this.newSession()
          return
        }
      }
      this.persist()
    }
  }

  persist(): void {
    const s = this.sessions.find(x => x.id === this.curSession)
    if (s !== undefined) {
      s.msgs = this.msgs
      s.updatedAt = Date.now()
    }
    AiStore.write(this.filesDir, this.sessions)
  }

  send(): void {
    const t = this.input.trim()
    if (t === '' || this.busy) {
      return
    }
    // AI Agent 终端执行模式:命令回路(确认→执行→总结)
    if (this.agentMode) {
      this.input = ''
      this.busy = true
      this.msgs.push({ role: 'user', text: '⚙ ' + t, ts: Date.now() })
      TerminalAgent.onEvent = (e: AgentEvent): void => {
        if (e.kind === 'need_confirm') {
          this.confirmCmd = e.text
        } else {
          this.msgs.push({ role: 'assistant', text: e.kind === 'cmd' ? '$ ' + e.text : e.text, ts: Date.now() })
          if (e.kind === 'done' || e.kind === 'err') {
            this.busy = false
          }
        }
        this.persist()
      }
      TerminalAgent.run(t, '').then(() => {
      })
      return
    }
    this.msgs.push({ role: 'user', text: t, ts: Date.now() })
    if (this.msgs.length === 1) {
      const s = this.sessions.find(x => x.id === this.curSession)
      if (s !== undefined) {
        s.name = t.length > 12 ? t.substring(0, 12) : t
      }
    }
    this.input = ''
    const cfg = LlmConfigStore.read(this.filesDir)
    if (cfg.apiKey === '') {
      this.msgs.push({ role: 'assistant', text: '未配置模型——点右上 ⚙ 填入 API Key 后即可对话(兼容 Anthropic/OpenAI 协议)。', ts: Date.now() })
      this.persist()
      return
    }
    this.busy = true
    const hist: LlmMsg[] = this.msgs.slice(-20).map(m => {
      return { role: m.role, text: m.text } as LlmMsg
    })
    Llm.chat(cfg, hist, '你是 uniTerm 的终端 AI 助理,帮助用户管理服务器与执行命令。回答简洁准确,使用中文。').then((out: string) => {
      this.msgs.push({ role: 'assistant', text: out, ts: Date.now() })
      this.busy = false
      this.persist()
    }).catch((e: Object) => {
      this.msgs.push({ role: 'assistant', text: '调用失败: ' + (e !== null && e !== undefined ? e.toString().substring(0, 300) : 'unknown'), ts: Date.now() })
      this.busy = false
      this.persist()
    })
  }

  @Builder
  HeaderBtn(icon: string, tip: string, cb: () => void) {
    Text(icon)
      .fontSize(13)
      .fontColor(0x9ea3ae)
      .width(24)
      .height(24)
      .textAlign(TextAlign.Center)
      .borderRadius(4)
      .margin({ left: 2 })
      .onClick(() => cb())
  }

  build() {
    Column() {
      // ai-header
      Row() {
        Text(this.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(0xe6e8ed)
        Blank()
        this.HeaderBtn('✚', '新会话', () => this.newSession())
        this.HeaderBtn('⚙', '模型配置', () => {
          this.cfgVisible = !this.cfgVisible
        })
        this.HeaderBtn('◷', '历史', () => {
          if (this.sessions.length > 0) {
            this.selectSession(this.sessions[this.sessions.length - 1].id)
          }
        })
        this.HeaderBtn('⤢', '最大化', () => {})
        this.HeaderBtn('×', '关闭', () => {
          this.visible = false
        })
      }
      .width('100%')
      .height(36)
      .padding({ left: 12, right: 8 })
      .backgroundColor(0x191c24)

      // 模型配置面板(官方 settings→AI:provider/baseUrl/key/model)
      if (this.cfgVisible) {
        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Text('Anthropic').fontSize(11).fontColor(this.cfgProvider === 'anthropic' ? 0x22d3ee : 0x9ea3ae)
              .padding(6).borderRadius(4)
              .backgroundColor(this.cfgProvider === 'anthropic' ? 0x252933 : Color.Transparent)
              .onClick(() => {
                this.cfgProvider = 'anthropic'
                this.cfgBaseUrl = 'https://api.anthropic.com'
                this.cfgModel = 'claude-sonnet-4-5'
              })
            Text('OpenAI').fontSize(11).fontColor(this.cfgProvider === 'openai' ? 0x22d3ee : 0x9ea3ae)
              .padding(6).borderRadius(4)
              .backgroundColor(this.cfgProvider === 'openai' ? 0x252933 : Color.Transparent)
              .onClick(() => {
                this.cfgProvider = 'openai'
                this.cfgBaseUrl = 'https://api.openai.com/v1'
                this.cfgModel = 'gpt-4o-mini'
              })
          }
          TextInput({ placeholder: 'Base URL', text: this.cfgBaseUrl })
            .fontSize(11).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(4)
            .onChange((v: string) => {
              this.cfgBaseUrl = v
            })
          TextInput({ placeholder: 'API Key', text: this.cfgApiKey })
            .fontSize(11).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(4)
            .type(InputType.Password)
            .onChange((v: string) => {
              this.cfgApiKey = v
            })
          TextInput({ placeholder: 'Model', text: this.cfgModel })
            .fontSize(11).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(4)
            .onChange((v: string) => {
              this.cfgModel = v
            })
          Text('保存')
            .fontSize(11).fontColor(0xffffff).padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(0x22d3ee).borderRadius(4).alignSelf(ItemAlign.End)
            .onClick(() => this.saveCfg())
        }
        .width('100%')
        .padding(8)
        .backgroundColor(0x191c24)
      }

      // ai-messages
      List({ scroller: this.scroller }) {
        if (this.msgs.length === 0) {
          ListItem() {
            Column({ space: 6 }) {
              Text('🤖')
                .fontSize(28)
                .margin({ top: 40 })
              Text('AI 助理')
                .fontSize(14)
                .fontColor(0xe6e8ed)
              Text('自主执行多轮 Shell 命令的 AI Agent\n(模型接入按官方路线图推进)')
                .fontSize(11)
                .fontColor(0x9ea3ae)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
        }
        ForEach(this.msgs, (m: AiMsg, i: number) => {
          ListItem() {
            Column({ space: 4 }) {
              Text(m.role === 'user' ? '你' : 'AI')
                .fontSize(10)
                .fontColor(m.role === 'user' ? 0x22d3ee : 0x34d399)
              Text(m.text)
                .fontSize(12)
                .fontColor(0xe6e8ed)
                .padding(8)
                .borderRadius(6)
                .backgroundColor(m.role === 'user' ? 0x252933 : 0x1f222b)
            }
            .alignItems(m.role === 'user' ? HorizontalAlign.End : HorizontalAlign.Start)
            .width('100%')
            .margin({ bottom: 8 })
          }
        }, (m: AiMsg, i: number) => i.toString() + m.ts.toString())
        if (this.busy) {
          ListItem() {
            Text('AI 思考中…')
              .fontSize(11)
              .fontColor(0x9ea3ae)
              .padding(6)
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .padding(10)

      // ai-input
      Column() {
        TextInput({ placeholder: '给 AI 发送消息…', text: this.input })
          .fontSize(12)
          .fontColor(0xe6e8ed)
          .placeholderColor(0x6b7280)
          .backgroundColor(0x1f222b)
          .borderRadius(6)
          .onChange((v: string) => {
            this.input = v
          })
          .onSubmit(() => this.send())
        Row() {
          Text(this.agentMode ? '⚙ 终端执行' : '💬 对话')
            .fontSize(10)
            .fontColor(this.agentMode ? 0x22d3ee : 0x9ea3ae)
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .borderRadius(4)
            .backgroundColor(this.agentMode ? 0x252933 : Color.Transparent)
            .onClick(() => {
              this.agentMode = !this.agentMode
            })
          Text('⏎ 发送')
            .fontSize(11)
            .fontColor(0x22d3ee)
            .onClick(() => this.send())
          Blank()
          Text('0/2000')
            .fontSize(10)
            .fontColor(0x6b7280)
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .width('100%')
      .padding(10)
      .backgroundColor(0x191c24)

      // Agent 命令确认条(官方 confirm 对话框简化版)
      if (this.confirmCmd !== '') {
        Column({ space: 6 }) {
          Text('AI 请求执行命令:')
            .fontSize(10)
            .fontColor(0xf59e0b)
          Text(this.confirmCmd)
            .fontSize(11)
            .fontColor(0xe6e8ed)
            .fontFamily('monospace')
            .padding(6)
            .borderRadius(4)
            .backgroundColor(0x1f222b)
            .width('100%')
          Row({ space: 8 }) {
            Text('✓ 允许')
              .fontSize(11)
              .fontColor(0xffffff)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor(0x22d3ee)
              .borderRadius(4)
              .onClick(() => {
                this.confirmCmd = ''
                TerminalAgent.approve()
              })
            Text('✗ 拒绝')
              .fontSize(11)
              .fontColor(0xf87171)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor(0x252933)
              .borderRadius(4)
              .onClick(() => {
                this.confirmCmd = ''
                TerminalAgent.deny()
              })
          }
        }
        .width('100%')
        .padding(8)
        .backgroundColor(0x191c24)
      }
    }
    .width(300)
    .height('100%')
    .backgroundColor(0x14171d)
  }
}
