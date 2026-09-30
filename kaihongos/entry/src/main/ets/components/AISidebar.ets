// 官方 AISidebar 复刻(结构:ai-header 标题+新建/历史/搜索/最大化/关闭 | ai-messages | ai-input 输入区)
// AI 后端(Anthropic/OpenAI 协议)已接入;M6 relay1: 全量主题化 + 保存/发送 toast + 密钥框可见性修复 + 悬停 tooltip
import { common } from '@kit.AbilityKit';
import { AiStore } from '../service/AiStore';
import { Llm, LlmMsg } from '../service/Llm';
import { LlmConfigStore } from '../service/LlmConfigStore';
import { TerminalAgent, AgentEvent } from '../service/TerminalAgent';
import { AppTheme, themeByName } from '../common/AppTheme';

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
  @StorageProp('ut.theme') themeName: string = 'dark'
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
  @State showKey: boolean = false // 密钥明文切换(P0-2)
  @State toast: string = '' // 保存/发送反馈(P0-3)
  @State toastErr: boolean = false
  // tooltip 公共悬停态(P0-6): hoverTip 记录当前悬停目标 id
  @State hoverTip: string = ''
  @State hoverOn: boolean = false
  private filesDir: string = ''
  private scroller: Scroller = new Scroller()

  private th(): AppTheme {
    return themeByName(this.themeName)
  }

  private showToast(msg: string, isErr: boolean): void {
    this.toast = msg
    this.toastErr = isErr
  }

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
    // P0-1: write() 返回错误消息,失败时 toast 且不关面板
    const err = LlmConfigStore.write(this.filesDir, {
      provider: this.cfgProvider,
      baseUrl: this.cfgBaseUrl,
      apiKey: this.cfgApiKey,
      model: this.cfgModel
    })
    if (err === '') {
      this.showToast('已保存', false)
      this.cfgVisible = false
    } else {
      this.showToast(err, true)
    }
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
      this.showToast('请先在 ⚙ 模型配置中填入 API Key', true)
      return
    }
    this.busy = true
    const hist: LlmMsg[] = this.msgs.slice(-20).map(m => {
      return { role: m.role, text: m.text } as LlmMsg
    })
    Llm.chat(cfg, hist, '你是一站AI终端的终端 AI 助理,帮助用户管理服务器与执行命令。回答简洁准确,使用中文。').then((out: string) => {
      this.msgs.push({ role: 'assistant', text: out, ts: Date.now() })
      this.busy = false
      this.persist()
    }).catch((e: Object) => {
      const em = e !== null && e !== undefined ? e.toString().substring(0, 300) : 'unknown'
      this.msgs.push({ role: 'assistant', text: '调用失败: ' + em, ts: Date.now() })
      this.busy = false
      this.persist()
      this.showToast('AI 调用失败', true)
    })
  }

  @Builder
  HeaderBtn(icon: string, tip: string, tipId: string, cb: () => void) {
    Text(icon)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.th().inkSubtle)
      .width(24)
      .height(24)
      .textAlign(TextAlign.Center)
      .borderRadius(4)
      .margin({ left: 2 })
      .onClick(() => cb())
      .onHover((h: boolean) => {
        this.hoverTip = h ? tipId : ''
        this.hoverOn = h
      })
      .bindPopup(this.hoverOn && this.hoverTip === tipId, {
        message: tip,
        placementOnTop: true
      })
  }

  build() {
    Column() {
      // ai-header
      Row() {
        Text(this.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.th().ink)
        Blank()
        this.HeaderBtn('✚', '新建会话', 'aiNew', () => this.newSession())
        this.HeaderBtn('⚙', '模型配置:Provider / API Key / Model', 'aiCfg', () => {
          this.cfgVisible = !this.cfgVisible
        })
        this.HeaderBtn('◷', '切换到最近历史会话', 'aiHist', () => {
          if (this.sessions.length > 0) {
            this.selectSession(this.sessions[this.sessions.length - 1].id)
          }
        })
        this.HeaderBtn('⤢', '最大化', 'aiMax', () => {})
        this.HeaderBtn('×', '关闭 AI 侧栏', 'aiClose', () => {
          this.visible = false
        })
      }
      .width('100%')
      .height(36)
      .padding({ left: 12, right: 8 })
      .backgroundColor(this.th().panel)

      // 模型配置面板(官方 settings→AI:provider/baseUrl/key/model)
      if (this.cfgVisible) {
        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Text('Anthropic').fontSize(11)
              .fontColor(this.cfgProvider === 'anthropic' ? this.th().brand : this.th().inkSubtle)
              .padding(6).borderRadius(4)
              .backgroundColor(this.cfgProvider === 'anthropic' ? this.th().hover : Color.Transparent)
              .onClick(() => {
                this.cfgProvider = 'anthropic'
                this.cfgBaseUrl = 'https://api.anthropic.com'
                this.cfgModel = 'claude-sonnet-4-5'
              })
            Text('OpenAI').fontSize(11)
              .fontColor(this.cfgProvider === 'openai' ? this.th().brand : this.th().inkSubtle)
              .padding(6).borderRadius(4)
              .backgroundColor(this.cfgProvider === 'openai' ? this.th().hover : Color.Transparent)
              .onClick(() => {
                this.cfgProvider = 'openai'
                this.cfgBaseUrl = 'https://api.openai.com/v1'
                this.cfgModel = 'gpt-4o-mini'
              })
          }
          TextInput({ placeholder: 'Base URL(如 https://api.anthropic.com)', text: this.cfgBaseUrl })
            .fontSize(12).fontColor(this.th().ink)
            .placeholderColor(this.th().inkSubtle)
            .backgroundColor(this.th().panel)
            .borderRadius(4)
            .height(36)
            .border({ width: 1, color: this.th().hairline })
            .onChange((v: string) => {
              this.cfgBaseUrl = v
            })
          // P0-2: 密钥输入框修复——显式 36px 高 + 12px 字号 + 明文切换钮 + 边框,
          // 原先 11px 密文圆点无高度约束,在深底上近乎不可见。
          Row({ space: 6 }) {
            TextInput({ placeholder: 'API Key(右侧 👁 切换明文)', text: this.cfgApiKey })
              .fontSize(12).fontColor(this.th().ink)
              .placeholderColor(this.th().inkSubtle)
              .backgroundColor(this.th().panel)
              .borderRadius(4)
              .height(36)
              .layoutWeight(1)
              .border({ width: 1, color: this.th().hairline })
              .type(this.showKey ? InputType.Normal : InputType.Password)
              .onChange((v: string) => {
                this.cfgApiKey = v
              })
            Text('👁')
              .fontSize(14)
              .fontWeight(this.showKey ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.showKey ? this.th().brand : this.th().inkSubtle)
              .width(34).height(36)
              .textAlign(TextAlign.Center)
              .borderRadius(4)
              .backgroundColor(this.th().panel)
              .border({ width: 1, color: this.th().hairline })
              .onClick(() => {
                this.showKey = !this.showKey
              })
              .onHover((h: boolean) => {
                this.hoverTip = h ? 'keyEye' : ''
                this.hoverOn = h
              })
              .bindPopup(this.hoverOn && this.hoverTip === 'keyEye', {
                message: this.showKey ? '隐藏密钥' : '显示密钥明文',
                placementOnTop: true
              })
          }
          .width('100%')
          TextInput({ placeholder: 'Model(如 claude-sonnet-4-5)', text: this.cfgModel })
            .fontSize(12).fontColor(this.th().ink)
            .placeholderColor(this.th().inkSubtle)
            .backgroundColor(this.th().panel)
            .borderRadius(4)
            .height(36)
            .border({ width: 1, color: this.th().hairline })
            .onChange((v: string) => {
              this.cfgModel = v
            })
          Text('保存')
            .fontSize(12).fontColor(this.th().surface).padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .backgroundColor(this.th().brand).borderRadius(4).alignSelf(ItemAlign.End)
            .onClick(() => this.saveCfg())
            .onHover((h: boolean) => {
              this.hoverTip = h ? 'keySave' : ''
              this.hoverOn = h
            })
            .bindPopup(this.hoverOn && this.hoverTip === 'keySave', {
              message: '保存模型配置到本地(立即生效)',
              placementOnTop: true
            })
        }
        .width('100%')
        .padding(8)
        .backgroundColor(this.th().panel)
      }

      // P0-3: 保存/发送结果反馈条(点击可关闭)
      if (this.toast !== '') {
        Text(this.toast)
          .fontSize(11)
          .fontColor(this.toastErr ? this.th().danger : this.th().success)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(4)
          .backgroundColor(this.th().hover)
          .width('100%')
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .onClick(() => {
            this.toast = ''
          })
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
                .fontColor(this.th().ink)
              // M6 relay1: 更新过时文案(AI 已接入,不再提"官方路线图")
              Text('模型已接入(Anthropic / OpenAI 兼容)\n点右上 ⚙ 填入 API Key 即可对话\n或切到 ⚙ 终端执行,让 AI 代跑命令')
                .fontSize(11)
                .fontColor(this.th().inkSubtle)
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
                .fontColor(m.role === 'user' ? this.th().brand : this.th().success)
              Text(m.text)
                .fontSize(12)
                .fontColor(this.th().ink)
                .padding(8)
                .borderRadius(6)
                .backgroundColor(m.role === 'user' ? this.th().hover : this.th().panel)
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
              .fontColor(this.th().inkSubtle)
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
          .fontColor(this.th().ink)
          .placeholderColor(this.th().inkSubtle)
          .backgroundColor(this.th().panel)
          .border({ width: 1, color: this.th().hairline })
          .borderRadius(6)
          .height(36)
          .onChange((v: string) => {
            this.input = v
          })
          .onSubmit(() => this.send())
        Row() {
          Text(this.agentMode ? '⚙ 终端执行' : '💬 对话')
            .fontSize(10)
            .fontColor(this.agentMode ? this.th().brand : this.th().inkSubtle)
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .borderRadius(4)
            .backgroundColor(this.agentMode ? this.th().hover : Color.Transparent)
            .onClick(() => {
              this.agentMode = !this.agentMode
            })
            .onHover((h: boolean) => {
              this.hoverTip = h ? 'modeToggle' : ''
              this.hoverOn = h
            })
            .bindPopup(this.hoverOn && this.hoverTip === 'modeToggle', {
              message: this.agentMode ? '终端执行模式:AI 命令需你确认后执行,点击切回对话' : '对话模式:点击切换为 AI 终端执行',
              placementOnTop: true
            })
          Text('⏎ 发送')
            .fontSize(11)
            .fontColor(this.th().brand)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .onClick(() => this.send())
          Blank()
          Text(this.input.length.toString() + '/2000')
            .fontSize(10)
            .fontColor(this.th().inkSubtle)
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .width('100%')
      .padding(10)
      .backgroundColor(this.th().panel)

      // Agent 命令确认条(官方 confirm 对话框简化版)
      if (this.confirmCmd !== '') {
        Column({ space: 6 }) {
          Text('AI 请求执行命令:')
            .fontSize(10)
            .fontColor(this.th().warn)
          Text(this.confirmCmd)
            .fontSize(11)
            .fontColor(this.th().ink)
            .fontFamily('monospace')
            .padding(6)
            .borderRadius(4)
            .backgroundColor(this.th().panel)
            .width('100%')
          Row({ space: 8 }) {
            Text('✓ 允许')
              .fontSize(11)
              .fontColor(this.th().surface)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor(this.th().brand)
              .borderRadius(4)
              .onClick(() => {
                this.confirmCmd = ''
                TerminalAgent.approve()
              })
            Text('✗ 拒绝')
              .fontSize(11)
              .fontColor(this.th().danger)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor(this.th().hover)
              .borderRadius(4)
              .onClick(() => {
                this.confirmCmd = ''
                TerminalAgent.deny()
              })
          }
        }
        .width('100%')
        .padding(8)
        .backgroundColor(this.th().panel)
      }
    }
    .width(300)
    .height('100%')
    .backgroundColor(this.th().surface)
  }
}
