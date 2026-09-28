// 官方 SettingsTab 复刻:左侧分类(基础/终端/主题/语言/AI)+ 右侧配置区
import { LlmConfigStore } from '../service/LlmConfigStore';
import { common } from '@kit.AbilityKit';

@Component
export struct SettingsTab {
  @State cat: number = 0 // 0基础 1终端 2主题 3语言 4AI
  // 基础
  @State autoReconnect: boolean = true
  @State confirmClose: boolean = true
  // 终端
  @State fontSize: number = 14
  @State scrollback: number = 10000
  @State cols: number = 120
  // 主题
  @State theme: string = 'dark'
  onThemeChange: (t: string) => void = (t: string) => {
  }
  // 语言
  @State lang: string = 'zh-CN'
  // AI
  @State cfgProvider: string = 'anthropic'
  @State cfgBaseUrl: string = 'https://api.anthropic.com'
  @State cfgApiKey: string = ''
  @State cfgModel: string = 'claude-sonnet-4-5'
  private filesDir: string = ''

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    this.filesDir = ctx.filesDir
    const cfg = LlmConfigStore.read(this.filesDir)
    this.cfgProvider = cfg.provider
    this.cfgBaseUrl = cfg.baseUrl
    this.cfgApiKey = cfg.apiKey
    this.cfgModel = cfg.model
  }

  saveAi(): void {
    LlmConfigStore.write(this.filesDir, {
      provider: this.cfgProvider,
      baseUrl: this.cfgBaseUrl,
      apiKey: this.cfgApiKey,
      model: this.cfgModel
    })
  }

  @Builder
  CatItem(icon: string, label: string, idx: number) {
    Row({ space: 8 }) {
      Text(icon)
        .fontSize(13)
      Text(label)
        .fontSize(12)
        .fontColor(this.cat === idx ? 0x22d3ee : 0xe6e8ed)
    }
    .width('100%')
    .padding({ left: 12, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.cat === idx ? 0x252933 : Color.Transparent)
    .onClick(() => {
      this.cat = idx
    })
  }

  @Builder
  Row1(label: string, val: string): void {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(0xe6e8ed)
      Blank()
      Text(val)
        .fontSize(11)
        .fontColor(0x9ea3ae)
    }
    .width('100%')
    .padding(10)
    .borderRadius(6)
    .backgroundColor(0x191c24)
  }

  build() {
    Row() {
      // 左侧分类
      Column({ space: 2 }) {
        this.CatItem('⌂', '基础', 0)
        this.CatItem('▸', '终端', 1)
        this.CatItem('◑', '主题', 2)
        this.CatItem('文', '语言', 3)
        this.CatItem('✦', 'AI 模型', 4)
      }
      .width(140)
      .height('100%')
      .padding(8)
      .backgroundColor(0x14171d)

      // 右侧配置区
      Scroll() {
        Column({ space: 10 }) {
          if (this.cat === 0) {
            Text('基础')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xe6e8ed)
            this.Row1('启动时恢复上次会话', this.autoReconnect ? '开' : '关')
            this.Row1('关闭标签前确认', this.confirmClose ? '开' : '关')
            this.Row1('应用版本', 'v1.0.0 (KaihongOS 适配)')
            this.Row1('开源协议', 'Apache 2.0')
            this.Row1('官网', 'uniterm.net')
          } else if (this.cat === 1) {
            Text('终端')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xe6e8ed)
            this.Row1('字号', this.fontSize.toString() + 'px')
            this.Row1('回滚缓冲行数', this.scrollback.toString())
            this.Row1('初始列数', this.cols.toString())
            this.Row1('编码', 'UTF-8')
            this.Row1('退格键映射', 'DEL')
          } else if (this.cat === 2) {
            Text('主题')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xe6e8ed)
            Row({ space: 8 }) {
              ForEach(['dark', 'navy', 'light'], (n: string) => {
                Text(n === 'dark' ? '暗色' : n === 'navy' ? '深蓝' : '浅色')
                  .fontSize(12)
                  .fontColor(this.theme === n ? 0x22d3ee : 0x9ea3ae)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .borderRadius(6)
                  .backgroundColor(this.theme === n ? 0x252933 : 0x191c24)
                  .onClick(() => {
                    this.theme = n
                    this.onThemeChange(n)
                  })
              }, (n: string) => n)
            }
            .width('100%')
          } else if (this.cat === 3) {
            Text('语言')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xe6e8ed)
            Column({ space: 4 }) {
              ForEach(['zh-CN', 'en-US', 'ja-JP', 'ko-KR'], (l: string) => {
                Text(l)
                  .fontSize(12)
                  .fontColor(this.lang === l ? 0x22d3ee : 0x9ea3ae)
                  .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                  .borderRadius(6)
                  .backgroundColor(this.lang === l ? 0x252933 : 0x191c24)
                  .alignSelf(ItemAlign.Start)
                  .onClick(() => {
                    this.lang = l
                  })
              }, (l: string) => l)
            }
            .alignItems(HorizontalAlign.Start)
            Text('完整 9 语言按官方 i18n 资源接入')
              .fontSize(10)
              .fontColor(0x6b7280)
          } else {
            Text('AI 模型')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(0xe6e8ed)
            Row({ space: 8 }) {
              Text('Anthropic')
                .fontSize(12)
                .fontColor(this.cfgProvider === 'anthropic' ? 0x22d3ee : 0x9ea3ae)
                .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                .borderRadius(6)
                .backgroundColor(this.cfgProvider === 'anthropic' ? 0x252933 : 0x191c24)
                .onClick(() => {
                  this.cfgProvider = 'anthropic'
                  this.cfgBaseUrl = 'https://api.anthropic.com'
                  this.cfgModel = 'claude-sonnet-4-5'
                })
              Text('OpenAI')
                .fontSize(12)
                .fontColor(this.cfgProvider === 'openai' ? 0x22d3ee : 0x9ea3ae)
                .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                .borderRadius(6)
                .backgroundColor(this.cfgProvider === 'openai' ? 0x252933 : 0x191c24)
                .onClick(() => {
                  this.cfgProvider = 'openai'
                  this.cfgBaseUrl = 'https://api.openai.com/v1'
                  this.cfgModel = 'gpt-4o-mini'
                })
            }
            .width('100%')
            Column({ space: 6 }) {
              TextInput({ placeholder: 'Base URL', text: this.cfgBaseUrl })
                .fontSize(12)
                .fontColor(0xe6e8ed)
                .backgroundColor(0x1f222b)
                .borderRadius(6)
                .onChange((v: string) => {
                  this.cfgBaseUrl = v
                })
              TextInput({ placeholder: 'API Key', text: this.cfgApiKey })
                .fontSize(12)
                .fontColor(0xe6e8ed)
                .backgroundColor(0x1f222b)
                .borderRadius(6)
                .type(InputType.Password)
                .onChange((v: string) => {
                  this.cfgApiKey = v
                })
              TextInput({ placeholder: 'Model', text: this.cfgModel })
                .fontSize(12)
                .fontColor(0xe6e8ed)
                .backgroundColor(0x1f222b)
                .borderRadius(6)
                .onChange((v: string) => {
                  this.cfgModel = v
                })
              Text('保存')
                .fontSize(12)
                .fontColor(0xffffff)
                .padding({ left: 18, right: 18, top: 8, bottom: 8 })
                .backgroundColor(0x22d3ee)
                .borderRadius(6)
                .alignSelf(ItemAlign.Start)
                .onClick(() => this.saveAi())
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding(16)
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(0x191c24)
    }
    .width('100%')
    .height('100%')
  }
}
