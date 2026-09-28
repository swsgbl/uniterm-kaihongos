// 官方 MonitorTabContent 复刻(本地设备版):CPU/内存/磁盘/网络 实时监控卡片
// 数据源:/proc/stat /proc/meminfo /proc/net/dev /proc/loadavg + statfs(/data)
import fs from '@ohos.file.fs';
import statfs from '@ohos.statfs';

interface NetIo {
  rxKB: number
  txKB: number
}

@Component
export struct MonitorPanel {
  @State cpuPercent: number = 0
  @State memPercent: number = 0
  @State memText: string = '-'
  @State diskPercent: number = 0
  @State diskText: string = '-'
  @State rxRate: number = 0
  @State txRate: number = 0
  @State loadText: string = '-'
  private timer: number = -1
  private prevCpu: number[] = [0, 0, 0, 0, 0, 0, 0, 0]
  private prevNet: NetIo = { rxKB: 0, txKB: 0 }
  private prevTs: number = 0

  aboutToAppear(): void {
    this.sample()
    this.timer = setInterval(() => this.sample(), 3000)
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer)
    }
  }

  private readProc(path: string): string {
    try {
      return fs.readTextSync(path)
    } catch (e) {
      return ''
    }
  }

  private sample(): void {
    // CPU: /proc/stat 首行 cpu  user nice system idle iowait irq softirq steal
    const stat = this.readProc('/proc/stat')
    if (stat !== '') {
      const line = stat.split('\n')[0].trim().split(/\s+/)
      const cur: number[] = []
      for (let i = 1; i < line.length && i <= 8; i++) {
        cur.push(parseInt(line[i]) || 0)
      }
      let total = 0
      let idle = 0
      const prevTotal = this.prevCpu[0] + this.prevCpu[1] + this.prevCpu[2] + this.prevCpu[3] +
        this.prevCpu[4] + this.prevCpu[5] + this.prevCpu[6] + this.prevCpu[7]
      const prevIdle = this.prevCpu[3] + this.prevCpu[4]
      for (let i = 0; i < cur.length; i++) {
        total += cur[i]
        if (i === 3 || i === 4) {
          idle += cur[i]
        }
      }
      const dTotal = total - prevTotal
      const dIdle = idle - prevIdle
      if (dTotal > 0) {
        this.cpuPercent = Math.round((1 - dIdle / dTotal) * 100)
      }
      this.prevCpu = cur
    }
    // 内存: /proc/meminfo
    const mi = this.readProc('/proc/meminfo')
    if (mi !== '') {
      let total = 0
      let avail = 0
      const lines = mi.split('\n')
      for (const l of lines) {
        const digits: string = l.replace(/[^0-9]/g, '')
        if (l.startsWith('MemTotal:')) {
          total = parseInt(digits) || 0
        } else if (l.startsWith('MemAvailable:')) {
          avail = parseInt(digits) || 0
        }
      }
      if (total > 0) {
        const used = total - avail
        this.memPercent = Math.round(used / total * 100)
        this.memText = (used / 1048576).toFixed(1) + 'G / ' + (total / 1048576).toFixed(1) + 'G'
      }
    }
    // 网络: /proc/net/dev 累计字节 → 速率
    const nd = this.readProc('/proc/net/dev')
    if (nd !== '') {
      let rx = 0
      let tx = 0
      const lines = nd.split('\n')
      for (const l of lines) {
        const idx = l.indexOf(':')
        if (idx > 0) {
          const name = l.substring(0, idx).trim()
          if (name === 'lo') {
            continue
          }
          const cols = l.substring(idx + 1).trim().split(/\s+/)
          if (cols.length >= 9) {
            rx += parseInt(cols[0]) || 0
            tx += parseInt(cols[8]) || 0
          }
        }
      }
      const now = Date.now()
      if (this.prevTs > 0) {
        const dt = (now - this.prevTs) / 1000
        if (dt > 0.5) {
          this.rxRate = Math.max(0, Math.round((rx - this.prevNet.rxKB) / dt / 1024))
          this.txRate = Math.max(0, Math.round((tx - this.prevNet.txKB) / dt / 1024))
        }
      }
      this.prevNet = { rxKB: rx, txKB: tx }
      this.prevTs = now
    }
    // 负载: /proc/loadavg
    const la = this.readProc('/proc/loadavg')
    if (la !== '') {
      const p = la.trim().split(/\s+/)
      if (p.length >= 3) {
        this.loadText = p[0] + ' ' + p[1] + ' ' + p[2]
      }
    }
    // 磁盘: statfs getFreeBytes/getTotalBytes(Promise)
    statfs.getTotalBytes('/data').then((totalB: number) => {
      statfs.getFreeBytes('/data').then((freeB: number) => {
        if (totalB > 0) {
          this.diskPercent = Math.round((1 - freeB / totalB) * 100)
          this.diskText = ((totalB - freeB) / 1073741824).toFixed(1) + 'G / ' + (totalB / 1073741824).toFixed(1) + 'G'
        }
      })
    }).catch(() => {
    })
  }

  @Builder
  Card(title: string, pct: number, text: string, color: number) {
    Column({ space: 6 }) {
      Row() {
        Text(title)
          .fontSize(12)
          .fontColor(0x9ea3ae)
        Blank()
        Text(pct.toString() + '%')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(color)
      }
      .width('100%')
      Progress({ value: pct, total: 100, type: ProgressType.Linear })
        .color(color)
        .backgroundColor(0x1f222b)
        .width('100%')
      Text(text)
        .fontSize(11)
        .fontColor(0x9ea3ae)
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor(0x191c24)
  }

  build() {
    Column({ space: 10 }) {
      Text('服务器监控')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(0xe6e8ed)
        .padding({ top: 10, bottom: 2 })
      this.Card('CPU', this.cpuPercent, '负载 ' + this.loadText, 0x22d3ee)
      this.Card('内存', this.memPercent, this.memText, 0x34d399)
      this.Card('磁盘 /data', this.diskPercent, this.diskText, 0xf59e0b)
      Row({ space: 10 }) {
        Column({ space: 4 }) {
          Text('↓ ' + this.rxRate.toString() + ' KB/s')
            .fontSize(12)
            .fontColor(0x4c9df0)
          Text('下行')
            .fontSize(10)
            .fontColor(0x9ea3ae)
        }
        .layoutWeight(1)
        .padding(10)
        .borderRadius(8)
        .backgroundColor(0x191c24)
        Column({ space: 4 }) {
          Text('↑ ' + this.txRate.toString() + ' KB/s')
            .fontSize(12)
            .fontColor(0xa78bfa)
          Text('上行')
            .fontSize(10)
            .fontColor(0x9ea3ae)
        }
        .layoutWeight(1)
        .padding(10)
        .borderRadius(8)
        .backgroundColor(0x191c24)
      }
      .width('100%')
      Blank()
      Text('3s 刷新 · 远程主机监控(经 SSH)按官方路线接入')
        .fontSize(10)
        .fontColor(0x6b7280)
        .padding(8)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10 })
    .backgroundColor(0x14171d)
    .alignItems(HorizontalAlign.Start)
  }
}
