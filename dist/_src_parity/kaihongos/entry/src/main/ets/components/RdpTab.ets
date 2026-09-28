import { RdpNapi } from 'librdpproxy.so';
import image from '@ohos.multimedia.image';

@Component
export struct RdpTab {
  @State host: string = ''
  @State port: string = '3389'
  @State user: string = 'Administrator'
  @State password: string = ''
  @State connected: boolean = false
  @State errText: string = ''
  @State pm: image.PixelMap | null = null
  private fb: Uint8Array | null = null
  private fbW: number = 0
  private fbH: number = 0
  private mod: RdpNapi | null = null

  aboutToDisappear(): void {
    this.disconnect()
  }

  disconnect(): void {
    if (this.mod !== null) {
      this.mod.rdpDisconnect()
    }
    this.connected = false
  }

  doConnect(): void {
    const h = this.host.trim()
    if (h === '') {
      this.errText = '请输入主机地址'
      return
    }
    this.errText = ''
    try {
      if (this.mod === null) {
        this.mod = new RdpNapi()
      }
      this.connected = true
      this.mod.rdpConnect(h, parseInt(this.port) || 3389, this.user, this.password, 1024, 768,
        (x: number, y: number, w: number, h: number, ab: ArrayBuffer): void => {
          this.deliver(x, y, w, h, new Uint8Array(ab))
        })
    } catch (e) {
      this.connected = false
      this.errText = 'rdpproxy 加载失败: ' + JSON.stringify(e).substring(0, 200)
    }
  }

  deliver(x: number, y: number, w: number, h: number, rgba: Uint8Array): void {
    if (this.fb === null || this.fbW * this.fbH < (y + h) * (x + w)) {
      // 首帧或 resize:分配全屏缓冲
      this.fbW = x + w
      this.fbH = y + h
      this.fb = new Uint8Array(this.fbW * this.fbH * 4)
    }
    // 贴矩形
    for (let r = 0; r < h; r++) {
      const dOff = ((y + r) * this.fbW + x) * 4
      const sOff = r * w * 4
      for (let c = 0; c < w * 4; c++) {
        this.fb[dOff + c] = rgba[sOff + c]
      }
    }
    image.createPixelMap(this.fb.buffer, { size: { width: this.fbW, height: this.fbH } }).then((pm: image.PixelMap) => {
      this.pm = pm
    })
  }

  build() {
    Column() {
      if (!this.connected) {
        Column({ space: 12 }) {
          Blank()
          Text('🖥').fontSize(40)
          Text('RDP 远程桌面')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(0xe6e8ed)
          Text('FreerDP 3.9 · NAPI 桥 · x86_64')
            .fontSize(11)
            .fontColor(0x9ea3ae)
          TextInput({ placeholder: '主机 (如 192.168.1.10)', text: this.host })
            .fontSize(13).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).width(280)
            .onChange((v: string) => {
              this.host = v
            })
          TextInput({ placeholder: '端口 (默认 3389)', text: this.port })
            .fontSize(13).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).width(280)
            .type(InputType.Number)
            .onChange((v: string) => {
              this.port = v
            })
          TextInput({ placeholder: '用户名', text: this.user })
            .fontSize(13).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).width(280)
            .onChange((v: string) => {
              this.user = v
            })
          TextInput({ placeholder: '密码', text: this.password })
            .fontSize(13).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).width(280)
            .type(InputType.Password)
            .onChange((v: string) => {
              this.password = v
            })
          Text('连接')
            .fontSize(14).fontColor(0x14171d).fontWeight(FontWeight.Bold)
            .padding({ left: 30, right: 30, top: 9, bottom: 9 })
            .backgroundColor(0x22d3ee).borderRadius(6)
            .onClick(() => this.doConnect())
          if (this.errText !== '') {
            Text(this.errText).fontSize(11).fontColor(0xf87171).padding(6)
          }
          Blank()
        }
        .width('100%').height('100%').backgroundColor(0x14171d)
      } else {
        Column() {
          Row() {
            Text('RDP ' + this.host + ':' + this.port)
              .fontSize(12).fontColor(0xe6e8ed)
            Blank()
            Text(this.fbW.toString() + 'x' + this.fbH.toString())
              .fontSize(11).fontColor(0x9ea3ae)
            Text('断开')
              .fontSize(11).fontColor(0xf87171)
              .padding({ left: 8, right: 8 })
              .onClick(() => this.disconnect())
          }
          .width('100%').padding(8).backgroundColor(0x191c24)
          if (this.pm !== null) {
            Image(this.pm)
              .objectFit(ImageFit.Contain)
              .layoutWeight(1)
              .width('100%')
          } else {
            Column({ space: 8 }) {
              LoadingProgress().width(32).height(32).color(0x22d3ee)
              Text('正在协商 RDP 连接…')
                .fontSize(11).fontColor(0x9ea3ae)
            }
            .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center)
          }
        }
        .width('100%').height('100%')
      }
    }
    .width('100%').height('100%')
  }
}
