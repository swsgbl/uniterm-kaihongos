// Redis 标签页(官方 DatabaseTab→Redis 子集):连接 + 命令执行
import { RedisService } from '../service/RedisService';

@Component
export struct RedisTab {
  @State host: string = ''
  @State port: string = '6379'
  @State connected: boolean = false
  @State cmd: string = ''
  @State out: string = ''
  @State busy: boolean = false

  doConnect(): void {
    if (this.host.trim() === '') {
      this.out = '请填 host'
      return
    }
    const p = parseInt(this.port) || 6379
    RedisService.connect(this.host.trim(), p).then(() => {
      this.connected = true
      this.out = '已连接 ' + this.host + ':' + this.port
    }).catch((e: Object) => {
      this.out = '连接失败: ' + e.toString().substring(0, 200)
    })
  }

  doExec(): void {
    if (this.cmd.trim() === '' || this.busy) {
      return
    }
    this.busy = true
    this.out = '...'
    RedisService.exec(this.cmd).then((r: string) => {
      this.out = r
      this.busy = false
    }).catch((e: Object) => {
      this.out = e.toString().substring(0, 500)
      this.busy = false
    })
  }

  build() {
    Column({ space: 10 }) {
      Text('Redis')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(0xe6e8ed)
        .alignSelf(ItemAlign.Start)
      if (!this.connected) {
        Row({ space: 8 }) {
          TextInput({ placeholder: 'host', text: this.host })
            .fontSize(12)
            .fontColor(0xe6e8ed)
            .backgroundColor(0x1f222b)
            .borderRadius(6)
            .layoutWeight(2)
            .onChange((v: string) => {
              this.host = v
            })
          TextInput({ placeholder: '端口', text: this.port })
            .fontSize(12)
            .fontColor(0xe6e8ed)
            .backgroundColor(0x1f222b)
            .borderRadius(6)
            .layoutWeight(1)
            .onChange((v: string) => {
              this.port = v
            })
          Text('连接')
            .fontSize(12)
            .fontColor(0xffffff)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(0x22d3ee)
            .borderRadius(6)
            .onClick(() => this.doConnect())
        }
        .width('100%')
      } else {
        Row({ space: 8 }) {
          Text('● ' + this.host + ':' + this.port)
            .fontSize(12)
            .fontColor(0x34d399)
            .layoutWeight(1)
          Text('断开')
            .fontSize(11)
            .fontColor(0xf87171)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(0x252933)
            .borderRadius(4)
            .onClick(() => {
              RedisService.close()
              this.connected = false
              this.out = ''
            })
        }
        .width('100%')
        TextInput({ placeholder: '命令,如 PING / INFO / KEYS *', text: this.cmd })
          .fontSize(12)
          .fontColor(0xe6e8ed)
          .backgroundColor(0x1f222b)
          .borderRadius(6)
          .onChange((v: string) => {
            this.cmd = v
          })
          .onSubmit(() => this.doExec())
        Row({ space: 6 }) {
          ForEach(['PING', 'INFO server', 'DBSIZE', 'CONFIG GET maxmemory'], (q: string) => {
            Text(q)
              .fontSize(10)
              .fontColor(0x9ea3ae)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(0x1f222b)
              .borderRadius(4)
              .onClick(() => {
                this.cmd = q
                this.doExec()
              })
          }, (q: string) => q)
        }
        .width('100%')
      }
      Scroll() {
        Text(this.out === '' ? ' ' : this.out)
          .fontSize(11)
          .fontColor(0xe6e8ed)
          .fontFamily('monospace')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(0x14171d)
      .borderRadius(6)
      .padding(8)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .padding(14)
    .backgroundColor(0x191c24)
    .alignItems(HorizontalAlign.Start)
  }
}
