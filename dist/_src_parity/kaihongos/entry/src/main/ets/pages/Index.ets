// 官方 uniterm 外壳复刻:AppHeader(TabsList) + Sidebar(7视图) + StartTab
import { ConnectionStore } from '../store/ConnStore';
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
  @State showSettings: boolean = false
  @State aiVisible: boolean = false
  @State splitTabId: number = -1 // 分屏右侧固定的标签(-1 关闭)
  private th: UniTheme = themeByName('dark')

  aboutToAppear(): void {
    this.applyTheme(this.themeName)
    // 终端页内嵌后的跨组件信号:SFTP 打开 / 标签关闭
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
  }

  activeTabKind(): string {
    const t = this.tabs.find(x => x.id === this.activeTab)
    return t !== undefined ? t.kind : 'start'
  }

  activeConnId(): string {
    const t = this.tabs.find(x => x.id === this.activeTab)
    return t !== undefined && t.kind === 'terminal' ? t.connId : ''
  }

  addStartTab(): void {
    // 官方:+ 按钮新增开始页
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: '开始', kind: 'start', connId: '' })
    this.activeTab = id
  }

  openConnTab(connId: string): void {
    // 官方:双击/点击连接 → 新终端标签页
    const existing = this.tabs.find(t => t.kind === 'terminal' && t.connId === connId)
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: '终端 ' + connId, kind: 'terminal', connId: connId })
    this.activeTab = id
  }

  toggleSplit(): void {
    // 分屏:右侧固定当前标签(SFTP/设置/开始 可分屏;终端会话互斥不分屏)
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

  openVncTab(): void {
    const existing = this.tabs.find(t => t.kind === 'vnc')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'VNC', kind: 'vnc', connId: '' })
    this.activeTab = id
  }

  openMySqlTab(): void {
    const existing = this.tabs.find(t => t.kind === 'mysql')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'MySQL', kind: 'mysql', connId: '' })
    this.activeTab = id
  }

  openSpiceTab(): void {
    const existing = this.tabs.find(t => t.kind === 'spice')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'SPICE', kind: 'spice', connId: '' })
    this.activeTab = id
  }

  openRdpTab(): void {
    const existing = this.tabs.find(t => t.kind === 'rdp')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'RDP', kind: 'rdp', connId: '' })
    this.activeTab = id
  }

  openPgTab(): void {
    const existing = this.tabs.find(t => t.kind === 'pg')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'PostgreSQL', kind: 'pg', connId: '' })
    this.activeTab = id
  }

  openK8sTab(): void {
    const existing = this.tabs.find(t => t.kind === 'k8s')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'K8s', kind: 'k8s', connId: '' })
    this.activeTab = id
  }

  openRedisTab(): void {
    const existing = this.tabs.find(t => t.kind === 'redis')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'Redis', kind: 'redis', connId: '' })
    this.activeTab = id
  }

  openSettingsTab(): void {
    // 官方:设置菜单→设置 打开 SettingsTab 标签页
    const existing = this.tabs.find(t => t.kind === 'settings')
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: '设置', kind: 'settings', connId: '' })
    this.activeTab = id
  }

  openSftpTab(connId: string): void {
    // 官方:终端内打开 SFTP 双栏文件管理(经当前 SSH 会话)
    const existing = this.tabs.find(t => t.kind === 'sftp' && t.connId === connId)
    if (existing !== undefined) {
      this.activeTab = existing.id
      return
    }
    const id = this.nextTabId++
    this.tabs.push({ id: id, name: 'SFTP ' + connId, kind: 'sftp', connId: connId })
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

  @Builder
  HeaderBtn(icon: string, title: string, action: () => void) {
    Text(icon)
      .fontSize(14)
      .fontColor(this.th.textSecondary)
      .width(30)
      .height(30)
      .textAlign(TextAlign.Center)
      .borderRadius(6)
      .backgroundColor(this.th.bgSurface)
      .margin({ left: 4, right: 4 })
      .onClick(() => action())
      .onHover(() => {})
  }

  @Builder
  TabItem(t: TabInfo) {
    Row({ space: 5 }) {
      Text(t.kind === 'start' ? '⌂' : (t.kind === 'sftp' ? '▦' : '▸'))
        .fontSize(11)
        .fontColor(t.id === this.activeTab ? this.th.accent : this.th.textSecondary)
      Text(t.name)
        .fontSize(12)
        .fontColor(t.id === this.activeTab ? this.th.textPrimary : this.th.textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (t.kind === 'terminal') {
        Text('▦')
          .fontSize(11)
          .fontColor(this.th.textSecondary)
          .padding({ left: 2, right: 2 })
          .onClick(() => this.openSftpTab(t.connId))
      }
      Text('×')
        .fontSize(12)
        .fontColor(this.th.textSecondary)
        .onClick(() => this.closeTab(t.id))
    }
    .padding({ left: 10, right: 8, top: 5, bottom: 5 })
    .borderRadius(6)
    .backgroundColor(t.id === this.activeTab ? this.th.bgOverlay : Color.Transparent)
    .margin({ right: 2 })
    .onClick(() => {
      this.activeTab = t.id
    })
  }

  @Builder
  SideIcon(icon: string, idx: number, tip: string) {
    Text(icon)
      .fontSize(14)
      .fontColor(this.sideView === idx ? this.th.accent : this.th.textSecondary)
      .width(30)
      .height(30)
      .textAlign(TextAlign.Center)
      .borderRadius(6)
      .backgroundColor(this.sideView === idx ? this.th.bgOverlay : Color.Transparent)
      .margin({ right: 2 })
      .onClick(() => {
        this.sideView = idx
      })
  }

  @Builder
  StartPane() {
    Column({ space: 12 }) {
      Blank()
      Text('uniTerm')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.th.textPrimary)
      Text('轻量级一站式终端软件 · KaihongOS 适配版')
        .fontSize(13)
        .fontColor(this.th.textSecondary)
      Blank()
      Row({ space: 10 }) {
        Text('新建连接')
          .fontSize(13)
          .fontColor(0xffffff)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.th.accent)
          .borderRadius(6)
          .onClick(() => {
            this.sideView = 0
            this.sidebarVisible = true
          })
        Text('导入连接')
          .fontSize(13)
          .fontColor(this.th.textPrimary)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(this.th.bgSurface)
          .borderRadius(6)
          .onClick(() => {
            this.sideView = 0
            this.sidebarVisible = true
          })
      }
      Blank()
      Text('SSH / Telnet / SFTP / RDP / VNC / 数据库 / K8s · 30+ 协议')
        .fontSize(11)
        .fontColor(this.th.textSecondary)
        .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.th.bgBase)
  }

  build() {
    Column() {
      // ===== AppHeader =====
      Row() {
        this.HeaderBtn('▤', '', () => {
          this.sidebarVisible = !this.sidebarVisible
        })
        // TabsList
        Row() {
          ForEach(this.tabs, (t: TabInfo) => {
            this.TabItem(t)
          }, (t: TabInfo) => t.id.toString())
          Text('+')
            .fontSize(15)
            .fontColor(this.th.textSecondary)
            .width(26)
            .height(26)
            .textAlign(TextAlign.Center)
            .borderRadius(6)
            .onClick(() => this.addStartTab())
        }
        .layoutWeight(1)
        .height('100%')
        .margin({ left: 4 })
        Blank()
        this.HeaderBtn('▣', '分屏', () => this.toggleSplit())
        this.HeaderBtn('✦', 'AI', () => {
          this.aiVisible = !this.aiVisible
        })
        Text('⚙')
          .fontSize(14)
          .fontColor(this.showSettings ? this.th.accent : this.th.textSecondary)
          .width(30)
          .height(30)
          .textAlign(TextAlign.Center)
          .borderRadius(6)
          .margin({ left: 4, right: 6 })
          .onClick(() => {
            this.showSettings = !this.showSettings
          })
      }
      .width('100%')
      .height(38)
      .backgroundColor(this.th.bgElevated)
      .alignItems(VerticalAlign.Center)

      // ===== 主体 =====
      Row() {
        // Sidebar
        if (this.sidebarVisible) {
          Column() {
            // 7 视图图标条(官方:连接/文件/监控/隧道/快捷命令/历史/个性化)
            Row() {
              this.SideIcon('⌗', 0, '连接')
              this.SideIcon('▤', 1, '文件')
              this.SideIcon('∿', 2, '监控')
              this.SideIcon('⇄', 3, '隧道')
              this.SideIcon('⚡', 4, '快捷命令')
              this.SideIcon('◷', 5, '历史')
              this.SideIcon('◑', 6, '个性化')
              Blank()
              Text('«')
                .fontSize(13)
                .fontColor(this.th.textSecondary)
                .padding(4)
                .onClick(() => {
                  this.sidebarVisible = false
                })
            }
            .width('100%')
            .padding(4)

            if (this.sideView === 0) {
              // 连接视图:搜索 + 连接树(复用 ConnList)
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
              // 文件视图(官方 FileSidebar)
              FileSidebar()
                .layoutWeight(1)
            } else if (this.sideView === 2) {
              // 监控视图(官方 MonitorOverviewSidebar)
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
                Text(['文件', '监控', '隧道', '快捷命令', '历史', '个性化'][this.sideView - 1])
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
          .backgroundColor(this.th.bgElevated)
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
          .layoutWeight(this.splitTab() !== null ? 1 : 1)
          .height('100%')

          // 分屏右栏(官方 PanelGrid 两栏;终端互斥,右栏放 SFTP/设置/开始)
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

        // AI 侧栏(官方:右侧可调宽 AI 助理面板)
        if (this.aiVisible) {
          AISidebar({ visible: this.aiVisible })
        }

        // 设置下拉(官方:主题/语言/…)
        if (this.showSettings) {
          Column({ space: 2 }) {
            Text('主题')
              .fontSize(11)
              .fontColor(this.th.textSecondary)
              .padding(6)
            ForEach(['dark', 'navy', 'light'], (n: string) => {
              Text(n === 'dark' ? '暗色' : n === 'navy' ? '深蓝' : '浅色')
                .fontSize(12)
                .fontColor(this.themeName === n ? this.th.accent : this.th.textPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .borderRadius(4)
                .backgroundColor(this.themeName === n ? this.th.bgOverlay : Color.Transparent)
                .onClick(() => this.applyTheme(n))
            }, (n: string) => n)
            Text('⚙ 设置')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openSettingsTab()
              })
            Text('# Redis')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openRedisTab()
              })
            Text('☸ K8s')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openK8sTab()
              })
            Text('🐘 PostgreSQL')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openPgTab()
              })
            Text('🐬 MySQL')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openMySqlTab()
              })
            Text('🖥 VNC')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openVncTab()
              })
            Text('🏬 RDP')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openRdpTab()
              })
            Text('🌶 SPICE')
              .fontSize(12)
              .fontColor(this.th.textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .borderRadius(4)
              .onClick(() => {
                this.showSettings = false
                this.openSpiceTab()
              })
          }
          .width(120)
          .padding(6)
          .borderRadius(8)
          .backgroundColor(this.th.bgOverlay)
          .margin(8)
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

