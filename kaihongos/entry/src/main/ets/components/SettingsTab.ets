// 官方 SettingsTab 复刻:左侧分类(基础/终端/主题/语言/AI)+ 右侧配置区
// M6 relay1: 全量主题化(P0-4) + 保存 toast(P0-1/3) + 密钥框可见性修复(P0-2) + 悬停 tooltip(P0-6) + 版本号 v1.1.0
import { LlmConfigStore } from '../service/LlmConfigStore';
import { common } from '@kit.AbilityKit';
import { UniTheme, themeByName } from '../common/UniTheme';

@Component
export struct SettingsTab {
  @StorageProp('ut.theme') themeName: string = 'dark'
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
  @State showKey: boolean = false // 密钥明文切换(P0-2)
  @State toast: string = '' // 保存反馈(P0-3)
  @State toastErr: boolean = false
  // tooltip 公共悬停态(P0-6)
  @State hoverTip: string = ''
  @State hoverOn: boolean = false
  private filesDir: string = ''

  private th(): UniTheme {
    return themeByName(this.themeName)
  }

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    this.filesDir = ctx.filesDir
    const cfg = LlmConfigStore.read(this.filesDir)
    this.cfgProvider = cfg.provider
    this.cfgBaseUrl = cfg.baseUrl
    this.cfgApiKey = cfg.apiKey
    this.cfgModel = cfg.model
    this.theme = this.themeName
  }

  saveAi(): void {
    // P0-1: write() 返回错误消息,保存后立即 toast 反馈
    const err = LlmConfigStore.write(this.filesDir, {
      provider: this.cfgProvider,
      baseUrl: this.cfgBaseUrl,
      apiKey: this.cfgApiKey,
      model: this.cfgModel
    })
    if (err === '') {
      this.toast = 'AI 配置已保存'
      this.toastErr = false
    } else {
      this.toast = err
      this.toastErr = true
    }
  }

  @Builder
  CatItem(icon: string, label: string, idx: number) {
    Row({ space: 8 }) {
      Text(icon)
        .fontSize(13)
        .fontColor(this.cat === idx ? this.th().accent : this.th().textSecondary)
      Text(label)
        .fontSize(12)
        .fontColor(this.cat === idx ? this.th().accent : this.th().textPrimary)
    }
    .width('100%')
    .padding({ left: 12, top: 8, bottom: 8 })
    .borderRadius(6)
    .backgroundColor(this.cat === idx ? this.th().bgOverlay : Color.Transparent)
    .onClick(() => {
      this.cat = idx
    })
  }

  @Builder
  Row1(label: string, val: string): void {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(this.th().textPrimary)
      Blank()
      Text(val)
        .fontSize(11)
        .fontColor(this.th().textSecondary)
    }
    .width('100%')
    .padding(10)
    .borderRadius(6)
    .backgroundColor(this.th().bgSurface)
  }

  build() {
    Row() {
      // 左侧分类
      Column({ space: 2 }) {
        this.CatItem('🏠', '基础', 0)
        this.CatItem('⌨', '终端', 1)
        this.CatItem('🎨', '主题', 2)
        this.CatItem('🌐', '语言', 3)
        this.CatItem('🤖', 'AI 模型', 4)
      }
      .width(140)
      .height('100%')
      .padding(8)
      .backgroundColor(this.th().bgBase)

      // 右侧配置区
      Scroll() {
        Column({ space: 10 }) {
          if (this.cat === 0) {
            Text('基础')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.th().textPrimary)
            this.Row1('启动时恢复上次会话', this.autoReconnect ? '开' : '关')
            this.Row1('关闭标签前确认', this.confirmClose ? '开' : '关')
            this.Row1('应用版本', 'v1.1.0 (KaihongOS 适配)')
            this.Row1('开源协作', 'Apache 2.0')
            this.Row1('官网', 'uniterm.net')
          } else if (this.cat === 1) {
            Text('终端')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.th().textPrimary)
            this.Row1('字号', this.fontSize.toString() + 'px')
            this.Row1('回滚缓冲行数', this.scrollback.toString())
            this.Row1('初始列数', this.cols.toString())
            this.Row1('编码', 'UTF-8')
            this.Row1('退格键映射', 'DEL')
          } else if (this.cat === 2) {
            Text('主题')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.th().textPrimary)
            Row({ space: 8 }) {
              ForEach(['dark', 'navy', 'light'], (n: string) => {
                Text(n === 'dark' ? '暗色' : n === 'navy' ? '深蓝' : '浅色')
                  .fontSize(12)
                  .fontWeight(this.theme === n ? FontWeight.Medium : FontWeight.Normal)
                  .fontColor(this.theme === n ? this.th().accent : this.th().textSecondary)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .borderRadius(6)
                  .border({ width: 1, color: this.theme === n ? this.th().accent : this.th().border })
                  .backgroundColor(this.theme === n ? this.th().bgOverlay : this.th().bgSurface)
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
              .fontColor(this.th().textPrimary)
            Column({ space: 4 }) {
              ForEach(['zh-CN', 'en-US', 'ja-JP', 'ko-KR'], (l: string) => {
                Text(l)
                  .fontSize(12)
                  .fontColor(this.lang === l ? this.th().accent : this.th().textSecondary)
                  .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                  .borderRadius(6)
                  .border({ width: 1, color: this.lang === l ? this.th().accent : this.th().border })
                  .backgroundColor(this.lang === l ? this.th().bgOverlay : this.th().bgSurface)
                  .alignSelf(ItemAlign.Start)
                  .onClick(() => {
                    this.lang = l
                  })
              }, (l: string) => l)
            }
            .alignItems(HorizontalAlign.Start)
            Text('完整 9 语言按官方 i18n 资源接入')
              .fontSize(10)
              .fontColor(this.th().textSecondary)
          } else {
            Text('AI 模型')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.th().textPrimary)
            Row({ space: 8 }) {
              Text('Anthropic')
                .fontSize(12)
                .fontColor(this.cfgProvider === 'anthropic' ? this.th().accent : this.th().textSecondary)
                .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                .borderRadius(6)
                .border({ width: 1, color: this.cfgProvider === 'anthropic' ? this.th().accent : this.th().border })
                .backgroundColor(this.cfgProvider === 'anthropic' ? this.th().bgOverlay : this.th().bgSurface)
                .onClick(() => {
                  this.cfgProvider = 'anthropic'
                  this.cfgBaseUrl = 'https://api.anthropic.com'
                  this.cfgModel = 'claude-sonnet-4-5'
                })
              Text('OpenAI')
                .fontSize(12)
                .fontColor(this.cfgProvider === 'openai' ? this.th().accent : this.th().textSecondary)
                .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                .borderRadius(6)
                .border({ width: 1, color: this.cfgProvider === 'openai' ? this.th().accent : this.th().border })
                .backgroundColor(this.cfgProvider === 'openai' ? this.th().bgOverlay : this.th().bgSurface)
                .onClick(() => {
                  this.cfgProvider = 'openai'
                  this.cfgBaseUrl = 'https://api.openai.com/v1'
                  this.cfgModel = 'gpt-4o-mini'
                })
            }
            .width('100%')
            Column({ space: 6 }) {
              TextInput({ placeholder: 'Base URL(如 https://api.anthropic.com)', text: this.cfgBaseUrl })
                .fontSize(12)
                .fontColor(this.th().textPrimary)
                .placeholderColor(this.th().textSecondary)
                .backgroundColor(this.th().inputBg)
                .border({ width: 1, color: this.th().border })
                .borderRadius(6)
                .height(36)
                .onChange((v: string) => {
                  this.cfgBaseUrl = v
                })
              // P0-2: 密钥输入框修复——36px 高 + 12px 字号 + 明文切换 + 边框
              Row({ space: 6 }) {
                TextInput({ placeholder: 'API Key(右侧 👁 切换明文)', text: this.cfgApiKey })
                  .fontSize(12)
                  .fontColor(this.th().textPrimary)
                  .placeholderColor(this.th().textSecondary)
                  .backgroundColor(this.th().inputBg)
                  .border({ width: 1, color: this.th().border })
                  .borderRadius(6)
                  .height(36)
                  .layoutWeight(1)
                  .type(this.showKey ? InputType.Normal : InputType.Password)
                  .onChange((v: string) => {
                    this.cfgApiKey = v
                  })
                Text('👁')
                  .fontSize(14)
                  .fontWeight(this.showKey ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.showKey ? this.th().accent : this.th().textSecondary)
                  .width(34).height(36)
                  .textAlign(TextAlign.Center)
                  .borderRadius(6)
                  .backgroundColor(this.th().inputBg)
                  .border({ width: 1, color: this.th().border })
                  .onClick(() => {
                    this.showKey = !this.showKey
                  })
                  .onHover((h: boolean) => {
                    this.hoverTip = h ? 'stKeyEye' : ''
                    this.hoverOn = h
                  })
                  .bindPopup(this.hoverOn && this.hoverTip === 'stKeyEye', {
                    message: this.showKey ? '隐藏密钥' : '显示密钥明文',
                    placementOnTop: true
                  })
              }
              .width('100%')
              TextInput({ placeholder: 'Model(如 claude-sonnet-4-5)', text: this.cfgModel })
                .fontSize(12)
                .fontColor(this.th().textPrimary)
                .placeholderColor(this.th().textSecondary)
                .backgroundColor(this.th().inputBg)
                .border({ width: 1, color: this.th().border })
                .borderRadius(6)
                .height(36)
                .onChange((v: string) => {
                  this.cfgModel = v
                })
              Text('保存')
                .fontSize(12)
                .fontColor(this.th().bgBase)
                .padding({ left: 18, right: 18, top: 8, bottom: 8 })
                .backgroundColor(this.th().accent)
                .borderRadius(6)
                .alignSelf(ItemAlign.Start)
                .onClick(() => this.saveAi())
                .onHover((h: boolean) => {
                  this.hoverTip = h ? 'stKeySave' : ''
                  this.hoverOn = h
                })
                .bindPopup(this.hoverOn && this.hoverTip === 'stKeySave', {
                  message: '保存模型配置到本地(立即生效)',
                  placementOnTop: true
                })
              // P0-3: 保存结果反馈
              if (this.toast !== '') {
                Text(this.toast)
                  .fontSize(11)
                  .fontColor(this.toastErr ? this.th().danger : this.th().success)
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .borderRadius(4)
                  .backgroundColor(this.th().bgOverlay)
                  .alignSelf(ItemAlign.Start)
                  .onClick(() => {
                    this.toast = ''
                  })
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding(16)
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(this.th().bgSurface)
    }
    .width('100%')
    .height('100%')
  }
}
