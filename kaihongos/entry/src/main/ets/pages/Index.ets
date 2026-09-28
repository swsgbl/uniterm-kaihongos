// 官方 uniterm 外壳 1:1 复刻(v2):AppHeader 44px(TabsList)+ Sidebar 240px(7视图+搜索+连接树)+ StartTab
// 样式基准:upstream/frontend/src/style.css :root token(2026-09-27 规格书)
import { ConnectionStore, ConnRec } from '../store/ConnStore';
import { ConnList } from './ConnList';
import { TerminalPage } from './TerminalPage';
import { SftpPanel } from './SftpPanel';
import { AISidebar } from '../components/AISidebar';
import { MonitorPanel } from '../components/MonitorPanel';
import { FileSidebar } from '../components/FileSidebar';
import { QuickCommandsPanel, HistoryPanel, PersonalizationPanel } from '../components/SidePanels';
import { SettingsTab } from '../components/SettingsTab';
import { RedisTab } from '../components/RedisTab';
import { K8sTab } from '../components/K8sTab';
import { PgTab } from '../components/PgTab';
import { MySqlTab } from '../components/MySqlTab';
import { VncTab } from '../components/VncTab';
import { RdpTab } from '../components/RdpTab';
import { SpiceTab } from '../components/SpiceTab';
import { themeByName, UniTheme } from '../common/UniTheme';
import { common } from '@kit.AbilityKit';

interface TabInfo {
  id: number
  name: string
  kind: string // start/terminal/sftp/settings/redis/k8s/pg/mysql/vnc/rdp/spice
  connId: string
}

@Entry
@Component
struct Index {
  @State themeName: string = 'dark'
  @State sidebarVisible: boolean = true
  @State sideView: number = 0 // 0连接 1文件 2监控 3隧道 4快捷 5历史 6个性化
  @State tabs: TabInfo[] = [{ id: 0, name: '开始', kind: 'start', connId: '' }]
  @State activeTab: number = 0
  @State nextTabId: number = 1
  @State showSettingsMenu: boolean = false
  @State aiVisible: boolean = false
  @State splitTabId: number = -1 // 分屏右侧固定的标签(-1 关闭)
  @State searchText: string = ''
  private th: UniTheme = themeByName('dark')
  private sideIcons: string[] = ['⌗', '▤', '∿', '⇄', '⚡', '◷', '◑']
  private sideTips: string[] = ['连接', '文件', '监控', '隧道', '快捷命令', '历史', '个性化']

  aboutToAppear(): void {
    this.applyTheme(this.themeName)
    AppStorage.setOrCreate('ut.openSftp', '')
    AppStorage.setOrCreate('ut.closeTab', '')
    setInterval(() => {
      const sftp = AppStorage.get<string>('ut.openSftp')
      if (sftp !== null && sftp !== undefined && sftp !== '') {
        AppStorage.setOrCreate('ut.openSftp', '')
        this.openSftpTab(sftp)
      }
      const closeId = AppStorage.get<string>('ut.closeTab')
      if (closeId !== null && closeId !== undefined && closeId !== '') {
        AppStorage.setOrCreate('ut.closeTab', '')
        const t = this.tabs.find(x => x.connId === closeId)
        if (t !== undefined) {
          this.closeTab(t.id)
        }
      }
    }, 400)
  }

  applyTheme(name: string): void {
    this.themeName = name
    this.th = themeByName(name)
    AppStorage.setOrCreate('ut.theme', name)
  }

  activeTabKind(): string {
    const t = this.tabs.find(x => x.id === this.activeTab)
    return t !== undefined ? t.kind : 'start'
  }

  activeConnId(): string {
    const t = this.tabs.find(x => x.id === this.activeTab)
    return t !== undefined && (t.kind === 'terminal' || t.kind === 'sftp') ? t.connId : ''
  }

  addStartTab(): void {
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: '开始', kind: 'start', connId: '' })
    this.activeTab = id
  }

  openConnTab(connId: string): void {
    const existing = this.tabs.find(t => t.kind === 'terminal' && t.connId === connId)
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    let name = '终端'
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      const store = new ConnectionStore(ctx.filesDir)
      const c = store.connections.find((x: ConnRec) => x.id === connId)
      if (c !== undefined) {
        name = c.name !== '' ? c.name : (c.user + '@' + c.host)
      }
    } catch (e) {
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: name, kind: 'terminal', connId: connId })
    this.activeTab = id
  }

  toggleSplit(): void {
    const t = this.tabs.find(x => x.id === this.activeTab)
    if (t === undefined) {
      return
    }
    if (this.splitTabId === t.id) {
      this.splitTabId = -1
      return
    }
    if (t.kind === 'terminal') {
      return
    }
    this.splitTabId = t.id
  }

  splitTab(): TabInfo | null {
    if (this.splitTabId < 0) {
      return null
    }
    return this.tabs.find(x => x.id === this.splitTabId) ?? null
  }

  openKindTab(kind: string, name: string): void {
    const existing = this.tabs.find(t => t.kind === kind)
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: name, kind: kind, connId: '' })
    this.activeTab = id
  }

  openSettingsTab(): void {
    this.openKindTab('settings', '设置')
  }

  openSftpTab(connId: string): void {
    const existing = this.tabs.find(t => t.kind === 'sftp' && t.connId === connId)
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'SFTP', kind: 'sftp', connId: connId })
    this.activeTab = id
  }

  closeTab(id: number): void {
    if (this.tabs.length <= 1) {
      return
    }
    const idx = this.tabs.findIndex(t => t.id === id)
    this.tabs.splice(idx, 1)
    if (this.activeTab === id) {
      this.activeTab = this.tabs[Math.max(0, idx - 1)].id
    }
  }

  // ===== 官方 AppHeader 44px:连接切换钮 + TabsList(flex:1) + AI 钮 + 设置菜单 =====
  @Builder
  HeaderBtn(icon: string, tip: string, action: () => void) {
    Text(icon)
      .fontSize(14)
      .fontColor(this.th.textSecondary)
      .width(28)
      .height(28)
      .textAlign(TextAlign.Center)
      .borderRadius(4)
      .margin({ left: 2, right: 2 })
      .onClick(() => action())
  }

  @Builder
  TabItem(t: TabInfo) {
    Row({ space: 5 }) {
      Text(t.kind === 'start' ? '⌂' : (t.kind === 'sftp' ? '▦' : (t.kind === 'settings' ? '⚙' : '▸')))
        .fontSize(11)
        .fontColor(t.id === this.activeTab ? this.th.accent : this.th.textSecondary)
      Text(t.name)
        .fontSize(12)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(t.id === this.activeTab ? this.th.textPrimary : this.th.textSecondary)
        .constraintSize({ maxWidth: 220 })
      Blank()
      Text('×')
        .fontSize(12)
        .fontColor(this.th.textSecondary)
        .padding({ left: 3, right: 3 })
        .onClick(() => this.closeTab(t.id))
    }
    .height(28)
    .constraintSize({ minWidth: 120 })
    .padding({ left: 10, right: 6 })
    .borderRadius(4)
    .backgroundColor(t.id === this.activeTab ? this.th.bgOverlay : Color.Transparent)
    .margin({ left: 1, right: 1 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.activeTab = t.id
    })
  }

  @Builder
  SideIcon(idx: number) {
    Text(this.sideIcons[idx])
      .fontSize(14)
      .fontColor(this.sideView === idx ? this.th.accent : this.th.textSecondary)
      .width(26)
      .height(26)
      .textAlign(TextAlign.Center)
      .borderRadius(4)
      .backgroundColor(this.sideView === idx ? this.th.bgOverlay : Color.Transparent)
      .onClick(() => {
        this.sideView = idx
      })
  }

  // ===== 官方 StartTabContent:brand 2rem accent / 搜索行 / 按钮行 / 分节标签 / 240px 卡片网格 =====
  cardMeta(c: ConnRec): string {
    if (c.type === 'local') return 'local';
    let s = c.user + '@' + c.host;
    if (c.port !== 22) s += ':' + c.port.toString();
    return s;
  }

  cardIcon(c: ConnRec): string {
    if (c.type === 'local') return '▤';
    if (c.type === 'rdp') return '▣';
    if (c.type === 'vnc') return '◫';
    if (c.type === 'k8s') return '☸';
    if (c.type === 'redis' || c.type === 'mysql' || c.type === 'pg') return '⬮';
    return '⌗';
  }

  cardIconColor(c: ConnRec): string {
    if (c.type === 'local') return '#34d399';
    if (c.type === 'rdp') return '#60a5fa';
    if (c.type === 'vnc') return '#a78bfa';
    if (c.type === 'redis') return '#f87171';
    if (c.type === 'mysql' || c.type === 'pg') return '#f59e0b';
    return '#22d3ee';
  }

  @Builder
  StartConnCard(c: ConnRec) {
    Row({ space: 10 }) {
      Text(this.cardIcon(c))
        .fontSize(20)
        .fontColor(this.cardIconColor(c))
        .width(36)
        .height(36)
        .textAlign(TextAlign.Center)
        .borderRadius(7)
        .backgroundColor(this.th.bgOverlay)
      Column({ space: 2 }) {
        Text(c.name)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.th.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.cardMeta(c))
          .fontSize(11)
          .fontColor(this.th.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width(240)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .borderRadius(10)
    .backgroundColor(this.th.bgSurface)
    .border({ width: 1, color: this.th.border })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (c.type === 'ssh') {
        this.openConnTab(c.id)
      }
    })
  }

  @Builder
  StartPane() {
    Column() {
      Scroll() {
        Column() {
          Text('uniTerm')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.th.accent)
            .margin({ top: 56, bottom: 32 })
          Row({ space: 8 }) {
            Row({ space: 5 }) {
              Text('⏷')
                .fontSize(11)
                .fontColor(this.th.textSecondary)
              Text('All')
                .fontSize(12)
                .fontColor(this.th.textSecondary)
            }
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(6)
            .backgroundColor(this.th.bgSurface)
            .border({ width: 1, color: this.th.border })
            .alignItems(VerticalAlign.Center)
            TextInput({ placeholder: 'Search or quick connect...', text: this.searchText })
              .onChange((v: string) => {
                this.searchText = v
              })
              .fontSize(13)
              .fontColor(this.th.textPrimary)
              .placeholderColor(this.th.textSecondary)
              .height(32)
              .backgroundColor(this.th.bgSurface)
              .borderRadius(6)
              .padding({ left: 12, right: 12 })
              .layoutWeight(1)
              .underlineColor(Color.Transparent)
              .caretColor(this.th.accent)
          }
          .width(440)
          Row({ space: 10 }) {
            Row({ space: 6 }) {
              Text('+')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.th.bgBase)
              Text('New Connection')
                .fontSize(13)
                .fontColor(this.th.bgBase)
            }
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(6)
            .backgroundColor(this.th.accent)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.sideView = 0
              this.sidebarVisible = true
            })
            Row({ space: 6 }) {
              Text('▤')
                .fontSize(13)
                .fontColor(this.th.textPrimary)
              Text('Local Terminal')
                .fontSize(13)
                .fontColor(this.th.textPrimary)
            }
            .height(32)
            .padding({ left: 16, right: 16 })
            .borderRadius(6)
            .backgroundColor(this.th.bgSurface)
            .border({ width: 1, color: this.th.border })
            .alignItems(VerticalAlign.Center)
          }
          .margin({ top: 16, bottom: 20 })

          Text('RECENT')
            .fontSize(11)
            .fontColor(this.th.textSecondary)
            .letterSpacing(1)
            .alignSelf(ItemAlign.Start)
            .margin({ left: 40, bottom: 8 })
          Column({ space: 10 }) {
            Text('暂无连接,点击 New Connection 开始')
              .fontSize(13)
              .fontColor(this.th.textSecondary)
              .margin({ top: 40 })
          }
          .width('100%')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.th.bgBase)
    .alignItems(HorizontalAlign.Center)
  }

  // ===== 官方设置下拉菜单(顶栏齿轮) =====
  @Builder
  SettingsMenu() {
    Column({ space: 1 }) {
      Text('主题')
        .fontSize(11)
        .fontColor(this.th.textSecondary)
        .padding({ left: 10, right: 10, top: 6, bottom: 4 })
        .alignSelf(ItemAlign.Start)
      ForEach(['dark', 'navy', 'light'], (n: string) => {
        Text(n === 'dark' ? '● 暗色' : (n === 'navy' ? '● 深蓝' : '● 浅色'))
          .fontSize(12)
          .fontColor(this.themeName === n ? this.th.accent : this.th.textPrimary)
          .padding({ left: 24, right: 10, top: 6, bottom: 6 })
          .borderRadius(4)
          .backgroundColor(this.themeName === n ? this.th.bgSurface : Color.Transparent)
          .alignSelf(ItemAlign.Start)
          .onClick(() => this.applyTheme(n))
      }, (n: string) => n)
      Divider()
        .strokeWidth(1)
        .color(this.th.border)
        .margin({ top: 4, bottom: 4 })
      Text('设置')
        .fontSize(12)
        .fontColor(this.th.textPrimary)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(4)
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          this.showSettingsMenu = false
          this.openSettingsTab()
        })
      Text('导入 / 导出')
        .fontSize(12)
        .fontColor(this.th.textPrimary)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(4)
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          this.showSettingsMenu = false
          this.sideView = 0
          this.sidebarVisible = true
        })
      Text('关于')
        .fontSize(12)
        .fontColor(this.th.textPrimary)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(4)
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          this.showSettingsMenu = false
          this.openSettingsTab()
        })
      Divider()
        .strokeWidth(1)
        .color(this.th.border)
        .margin({ top: 4, bottom: 4 })
      Text('Redis / K8s / PostgreSQL / MySQL / VNC / RDP / SPICE')
        .fontSize(10)
        .fontColor(this.th.textSecondary)
        .padding({ left: 10, right: 10, top: 4, bottom: 6 })
        .alignSelf(ItemAlign.Start)
    }
    .width(200)
    .padding(6)
    .borderRadius(8)
    .backgroundColor(this.th.bgOverlay)
    .border({ width: 1, color: this.th.border })
    .position({ x: '78%', y: 4 })
    .shadow({ radius: 12, color: '#66000000', offsetX: 0, offsetY: 4 })
  }

  build() {
    Column() {
      // ===== AppHeader(官方 44px, bg-elevated) =====
      Column() {
        Row() {
          this.HeaderBtn('▤', '连接列表', () => {
            this.sidebarVisible = !this.sidebarVisible
          })
          Scroll() {
            Row({ space: 2 }) {
              ForEach(this.tabs, (t: TabInfo) => {
                this.TabItem(t)
              }, (t: TabInfo) => t.id.toString())
              Text('+')
                .fontSize(15)
                .fontColor(this.th.textSecondary)
                .width(28)
                .height(28)
                .textAlign(TextAlign.Center)
                .borderRadius(6)
                .onClick(() => this.addStartTab())
            }
            .alignItems(VerticalAlign.Center)
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .height(28)
          .margin({ left: 4 })
          Blank()
          this.HeaderBtn('▣', '分屏', () => this.toggleSplit())
          this.HeaderBtn('✦', 'AI', () => {
            this.aiVisible = !this.aiVisible
          })
          this.HeaderBtn('⚙', '设置', () => {
            this.showSettingsMenu = !this.showSettingsMenu
          })
        }
        .width('100%')
        .height(40)
        .padding({ left: 8, right: 8 })
        .alignItems(VerticalAlign.Center)
        Divider()
          .strokeWidth(1)
          .color('#2622d3ee')
      }
      .width('100%')
      .height(44)
      .backgroundColor(this.th.bgBase)

      // ===== 主体 =====
      Stack({ alignContent: Alignment.TopEnd }) {
        Row() {
          if (this.sidebarVisible) {
            Column() {
              Row({ space: 2 }) {
                ForEach([0, 1, 2, 3, 4, 5, 6], (i: number) => {
                  this.SideIcon(i)
                }, (i: number) => i.toString())
                Blank()
                Text('«')
                  .fontSize(13)
                  .fontColor(this.th.textSecondary)
                  .width(26)
                  .height(26)
                  .textAlign(TextAlign.Center)
                  .borderRadius(4)
                  .onClick(() => {
                    this.sidebarVisible = false
                  })
              }
              .width('100%')
              .padding({ left: 10, right: 10, top: 10, bottom: 6 })

              if (this.sideView === 0) {
                Row({ space: 4 }) {
                  TextInput({ placeholder: '搜索或快捷连接...', text: this.searchText })
                    .onChange((v: string) => {
                      this.searchText = v
                    })
                    .fontSize(12)
                    .fontColor(this.th.textPrimary)
                    .placeholderColor(this.th.textSecondary)
                    .height(28)
                    .backgroundColor(this.th.bgSurface)
                    .borderRadius(4)
                    .padding({ left: 10, right: 4 })
                    .layoutWeight(1)
                    .underlineColor(Color.Transparent)
                    .caretColor(this.th.accent)
                  Text('⏷')
                    .fontSize(11)
                    .fontColor(this.th.textSecondary)
                    .width(24)
                    .height(24)
                    .textAlign(TextAlign.Center)
                    .borderRadius(4)
                }
                .width('100%')
                .padding({ left: 10, right: 10, bottom: 6 })
              }

              if (this.sideView === 0) {
                ConnList({
                  onOpenConn: (id: string) => {
                    this.openConnTab(id)
                  },
                  onNeedStore: (): ConnectionStore => {
                    const ctx = getContext(this) as common.UIAbilityContext
                    return new ConnectionStore(ctx.filesDir)
                  }
                })
                  .layoutWeight(1)
              } else if (this.sideView === 1) {
                FileSidebar()
                  .layoutWeight(1)
              } else if (this.sideView === 2) {
                MonitorPanel()
                  .layoutWeight(1)
              } else if (this.sideView === 4) {
                QuickCommandsPanel()
                  .layoutWeight(1)
              } else if (this.sideView === 5) {
                HistoryPanel()
                  .layoutWeight(1)
              } else if (this.sideView === 6) {
                PersonalizationPanel({
                  onThemeChange: (t: string) => this.applyTheme(t)
                })
                  .layoutWeight(1)
              } else {
                Column() {
                  Text(this.sideTips[this.sideView])
                    .fontSize(13)
                    .fontColor(this.th.textSecondary)
                    .margin(16)
                  Text('按官方路线图逐步开放')
                    .fontSize(11)
                    .fontColor(this.th.textSecondary)
                }
                .layoutWeight(1)
                .width('100%')
              }
            }
            .width(280)
            .height('100%')
            .backgroundColor(this.th.bgBase)
          }

          // 内容区:主栏 + 可选分屏右栏
          Row() {
            Column() {
              if (this.activeTabKind() === 'terminal') {
                TerminalPage({ connIdIn: this.activeConnId() })
              } else if (this.activeTabKind() === 'sftp') {
                SftpPanel({
                  connIdIn: this.activeConnId(),
                  onClose: () => {
                    const t = this.tabs.find(x => x.id === this.activeTab)
                    if (t !== undefined) {
                      this.closeTab(t.id)
                    }
                  }
                })
              } else if (this.activeTabKind() === 'settings') {
                SettingsTab({
                  onThemeChange: (t: string) => this.applyTheme(t)
                })
              } else if (this.activeTabKind() === 'redis') {
                RedisTab()
              } else if (this.activeTabKind() === 'k8s') {
                K8sTab()
              } else if (this.activeTabKind() === 'pg') {
                PgTab()
              } else if (this.activeTabKind() === 'mysql') {
                MySqlTab()
              } else if (this.activeTabKind() === 'vnc') {
                VncTab()
              } else if (this.activeTabKind() === 'rdp') {
                RdpTab()
              } else if (this.activeTabKind() === 'spice') {
                SpiceTab()
              } else {
                this.StartPane()
              }
            }
            .layoutWeight(1)
            .height('100%')

            if (this.splitTab() !== null && this.splitTabId !== this.activeTab) {
              Column() {
                if (this.splitTab()!.kind === 'sftp') {
                  SftpPanel({
                    connIdIn: this.splitTab()!.connId,
                    onClose: () => {
                      this.splitTabId = -1
                    }
                  })
                } else if (this.splitTab()!.kind === 'settings') {
                  SettingsTab({
                    onThemeChange: (t: string) => this.applyTheme(t)
                  })
                } else {
                  this.StartPane()
                }
              }
              .layoutWeight(1)
              .height('100%')
            }
          }
          .layoutWeight(1)
          .height('100%')

          if (this.aiVisible) {
            AISidebar({ visible: this.aiVisible })
          }
        }
        .width('100%')
        .height('100%')

        if (this.showSettingsMenu) {
          this.SettingsMenu()
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.th.bgBase)
  }
}
