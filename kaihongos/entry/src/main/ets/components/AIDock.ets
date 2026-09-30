/**
 * M6 relay3 - AI 智能体 Dock(底部可折叠工作坞)。
 * 展开态 ~320px: Dock 头(输入行 + 模式三档切换 + 轮次指示 R1/12 + 折叠钮) +
 * 消息流(用户气泡/AI 气泡/工具卡三类; 工具卡=命令+结果摘要+审批按钮 允许/拒绝)。
 * 折叠态 28px 细条。复用 LlmConfigStore 配置 + AgentSettingsStore 三档。
 * 主题经 @StorageProp('ut.theme') 接入(relay1 P0-4 范式)。
 */
import { common } from '@kit.AbilityKit';
import { AppTheme, themeByName } from '../common/AppTheme';
import { AgentKernel, KernelEvent } from '../service/AgentKernel';
import { AgentSettings, AgentSettingsStore, ApprovalMode } from '../service/AgentSettingsStore';

/** Dock 消息条目(三类: user/assistant/tool + 审批态)。 */
class DockMsg {
  kind: string = 'user' // 'user' | 'assistant' | 'tool'
  text: string = ''
  name: string = ''
  args: string = ''
  result: string = ''
  callId: string = ''
  pending: boolean = false // 工具卡待审批(显示允许/拒绝按钮)
  refused: boolean = false
}

@Component
export struct AIDock {
  @StorageProp('ut.theme') themeName: string = 'dark'
  @State open: boolean = false
  @State input: string = ''
  @State msgs: DockMsg[] = []
  @State mode: ApprovalMode = 'confirm_all'
  @State round: number = 0
  @State running: boolean = false
  @State approvalPending: boolean = false
  @State msgSeq: number = 0
  private scroller: Scroller = new Scroller()
  private filesDir: string = ''
  private modeNames: string[] = ['全部确认', '仅危险', '全自动']
  private modeVals: ApprovalMode[] = ['confirm_all', 'confirm_dangerous', 'bypass']

  private th(): AppTheme {
    return themeByName(this.themeName)
  }

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    this.filesDir = ctx.filesDir
    const s = AgentSettingsStore.read(this.filesDir)
    this.mode = s.mode
    AgentKernel.onEvent = (e: KernelEvent): void => {
      this.onKernelEvent(e)
    }
  }

  aboutToDisappear(): void {
    AgentKernel.onEvent = (e: KernelEvent): void => {
    }
  }

  private pushMsg(m: DockMsg): void {
    this.msgSeq++
    this.msgs.push(m)
  }

  private onKernelEvent(e: KernelEvent): void {
    if (e.kind === 'user') {
      const m = new DockMsg()
      m.kind = 'user'
      m.text = e.text
      this.pushMsg(m)
    } else if (e.kind === 'assistant' || e.kind === 'done') {
      const m = new DockMsg()
      m.kind = 'assistant'
      m.text = e.text
      this.pushMsg(m)
    } else if (e.kind === 'tool') {
      const m = new DockMsg()
      m.kind = 'tool'
      m.name = e.name
      m.args = e.args
      m.result = e.result
      m.callId = e.callId
      this.pushMsg(m)
    } else if (e.kind === 'need_approval') {
      const m = new DockMsg()
      m.kind = 'tool'
      m.name = e.name
      m.args = e.args
      m.callId = e.callId
      m.pending = true
      this.pushMsg(m)
      this.approvalPending = true
    } else if (e.kind === 'round') {
      this.round = e.round
    } else if (e.kind === 'err') {
      const m = new DockMsg()
      m.kind = 'assistant'
      m.text = e.text
      this.pushMsg(m)
    }
    this.scrollBottom()
  }

  private scrollBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 50)
  }

  private send(): void {
    const t = this.input.trim()
    if (t === '' || this.running) {
      return
    }
    this.input = ''
    this.running = true
    AgentKernel.run(t).then(() => {
      this.running = false
    }).catch((e: Object) => {
      this.running = false
    })
  }

  private setMode(m: ApprovalMode): void {
    this.mode = m
    const s = new AgentSettings()
    s.mode = m
    AgentSettingsStore.write(this.filesDir, s)
  }

  private approve(callId: string): void {
    for (const m of this.msgs) {
      if (m.callId === callId && m.pending) {
        m.pending = false
      }
    }
    this.approvalPending = false
    AgentKernel.approve()
  }

  private deny(callId: string): void {
    for (const m of this.msgs) {
      if (m.callId === callId && m.pending) {
        m.pending = false
        m.refused = true
        m.result = '已拒绝执行'
      }
    }
    this.approvalPending = false
    AgentKernel.deny()
  }

  @Builder
  ModePill(label: string, idx: number) {
    Text(label)
      .fontSize(10)
      .fontColor(this.mode === this.modeVals[idx] ? this.th().surface : this.th().inkSubtle)
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .borderRadius(9)
      .border({ width: 1, color: this.mode === this.modeVals[idx] ? this.th().brand : this.th().hairline })
      .backgroundColor(this.mode === this.modeVals[idx] ? this.th().brand : Color.Transparent)
      .margin({ left: 4 })
      .onClick(() => this.setMode(this.modeVals[idx]))
  }

  @Builder
  MsgRow(m: DockMsg) {
    if (m.kind === 'user') {
      Row() {
        Blank()
        Text(m.text)
          .fontSize(12)
          .fontColor(this.th().surface)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .borderRadius(10)
          .backgroundColor(this.th().brand)
          .constraintSize({ maxWidth: '80%' })
      }
      .width('100%')
      .margin({ top: 6, bottom: 2 })
    } else if (m.kind === 'assistant') {
      Row() {
        Text(m.text)
          .fontSize(12)
          .fontColor(this.th().ink)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .borderRadius(10)
          .backgroundColor(this.th().panel)
          .border({ width: 1, color: this.th().hairline })
          .constraintSize({ maxWidth: '80%' })
      }
      .width('100%')
      .margin({ top: 6, bottom: 2 })
    } else {
      // 工具卡: 名称+命令 → 结果摘要 → 审批按钮(待审批时)
      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text('⚙ ' + m.name)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.th().brand)
          Text(m.args)
            .fontSize(11)
            .fontColor(this.th().ink)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        if (m.result !== '' && !m.pending) {
          Text(m.result)
            .fontSize(10)
            .fontColor(this.th().inkSubtle)
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .borderRadius(4)
            .backgroundColor(this.th().hover)
        }
        if (m.pending) {
          Row({ space: 8 }) {
            Text('允许')
              .fontSize(11)
              .fontColor(this.th().surface)
              .padding({ left: 14, right: 14, top: 4, bottom: 4 })
              .borderRadius(6)
              .backgroundColor(this.th().success)
              .onClick(() => this.approve(m.callId))
            Text('拒绝')
              .fontSize(11)
              .fontColor(this.th().surface)
              .padding({ left: 14, right: 14, top: 4, bottom: 4 })
              .borderRadius(6)
              .backgroundColor(this.th().danger)
              .onClick(() => this.deny(m.callId))
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
      }
      .width('100%')
      .padding(8)
      .borderRadius(8)
      .backgroundColor(this.th().hover)
      .border({ width: 1, color: this.th().hairline })
      .margin({ top: 4, bottom: 4 })
    }
  }

  build() {
    Column() {
      if (this.open) {
        // ===== Dock 头(32px): 标题+轮次 + 模式三档 + 折叠钮 =====
        Row({ space: 6 }) {
          Text('✦ 智能体')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.th().brand)
            .margin({ left: 10 })
          Text(this.running ? ('R' + this.round.toString() + '/12') : '空闲')
            .fontSize(10)
            .fontColor(this.running ? this.th().brand : this.th().inkSubtle)
          Blank()
          this.ModePill(this.modeNames[0], 0)
          this.ModePill(this.modeNames[1], 1)
          this.ModePill(this.modeNames[2], 2)
          Text('▾')
            .fontSize(12)
            .fontColor(this.th().inkSubtle)
            .width(26)
            .height(26)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.open = false
            })
        }
        .width('100%')
        .height(32)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(this.th().surfaceRaised)
        .border({ width: { bottom: 1 }, color: this.th().hairline })

        // ===== 消息流(layoutWeight 撑满中段) =====
        Scroll(this.scroller) {
          Column() {
            ForEach(this.msgs, (m: DockMsg) => {
              this.MsgRow(m)
            }, (m: DockMsg) => m.kind + '|' + m.callId + '|' + m.text.substring(0, 40) + '|' + m.pending.toString() + '|' + m.refused.toString())
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .padding({ left: 12, right: 12 })

        // ===== 输入行 =====
        Row({ space: 8 }) {
          TextInput({ placeholder: '描述任务,如: 在终端执行 uname -a 并告诉我内核版本号', text: this.input })
            .fontSize(12)
            .fontColor(this.th().ink)
            .placeholderColor(this.th().inkSubtle)
            .backgroundColor(this.th().inputBg)
            .border({ width: 1, color: this.th().hairline })
            .borderRadius(6)
            .height(32)
            .layoutWeight(1)
            .onChange((v: string) => {
              this.input = v
            })
            .onSubmit(() => this.send())
          Text(this.running ? '…' : '发送')
            .fontSize(12)
            .fontColor(this.th().surface)
            .padding({ left: 14, right: 14, top: 7, bottom: 7 })
            .borderRadius(6)
            .backgroundColor(this.running ? this.th().iconMuted : this.th().brand)
            .onClick(() => this.send())
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 6, bottom: 8 })
        .alignItems(VerticalAlign.Center)
      } else {
        // ===== 折叠态(28px 细条) =====
        Row({ space: 8 }) {
          Text('✦')
            .fontSize(12)
            .fontColor(this.th().brand)
          Text('智能体')
            .fontSize(11)
            .fontColor(this.th().inkSubtle)
          if (this.running) {
            Text('R' + this.round.toString() + '/12')
              .fontSize(10)
              .fontColor(this.th().brand)
          }
          Blank()
          Text('▴')
            .fontSize(12)
            .fontColor(this.th().inkSubtle)
        }
        .width('100%')
        .height(28)
        .padding({ left: 12, right: 12 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor(this.th().surfaceRaised)
        .border({ width: { top: 1 }, color: this.th().hairline })
        .onClick(() => {
          this.open = true
        })
      }
    }
    .width('100%')
    .height(this.open ? 320 : 28)
  }
}
