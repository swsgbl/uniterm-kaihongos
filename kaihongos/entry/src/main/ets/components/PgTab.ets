// PostgreSQL 标签页(官方 DatabaseTab→PostgreSQL 子集)
import { PgService } from '../service/PgService';

@Component
export struct PgTab {
  @State host: string = ''
  @State port: string = '5432'
  @State user: string = ''
  @State password: string = ''
  @State db: string = 'postgres'
  @State connected: boolean = false
  @State sql: string = ''
  @State out: string = ''
  @State busy: boolean = false

  doConnect(): void {
    if (this.host.trim() === '' || this.user.trim() === '') {
      this.out = '请填 host 和 user'
      return
    }
    this.out = '连接中...'
    const p = parseInt(this.port) || 5432
    PgService.connect(this.host.trim(), p, this.user.trim(), this.password, this.db.trim() === '' ? 'postgres' : this.db.trim())
      .then(() => {
        this.connected = true
        this.out = '已连接 ' + this.db
      })
      .catch((e: Object) => {
        this.out = e.toString().substring(0, 400)
      })
  }

  doExec(): void {
    if (this.sql.trim() === '' || this.busy) {
      return
    }
    this.busy = true
    this.out = '...'
    PgService.query(this.sql).then((r: string) => {
      this.out = r
      this.busy = false
    }).catch((e: Object) => {
      this.out = e.toString().substring(0, 500)
      this.busy = false
    })
  }

  build() {
    Column({ space: 10 }) {
      Text('PostgreSQL')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(0xe6e8ed)
        .alignSelf(ItemAlign.Start)
      if (!this.connected) {
        Row({ space: 6 }) {
          TextInput({ placeholder: 'host', text: this.host })
            .fontSize(12).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).layoutWeight(2)
            .onChange((v: string) => {
              this.host = v
            })
          TextInput({ placeholder: '5432', text: this.port })
            .fontSize(12).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).layoutWeight(1)
            .onChange((v: string) => {
              this.port = v
            })
        }
        .width('100%')
        Row({ space: 6 }) {
          TextInput({ placeholder: 'user', text: this.user })
            .fontSize(12).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).layoutWeight(1)
            .onChange((v: string) => {
              this.user = v
            })
          TextInput({ placeholder: '密码', text: this.password })
            .fontSize(12).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).layoutWeight(1)
            .type(InputType.Password)
            .onChange((v: string) => {
              this.password = v
            })
        }
        .width('100%')
        Row({ space: 6 }) {
          TextInput({ placeholder: '数据库', text: this.db })
            .fontSize(12).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6).layoutWeight(1)
            .onChange((v: string) => {
              this.db = v
            })
          Text('连接')
            .fontSize(12).fontColor(0xffffff)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(0x22d3ee).borderRadius(6)
            .onClick(() => this.doConnect())
        }
        .width('100%')
      } else {
        Row({ space: 8 }) {
          Text('● ' + this.user + '@' + this.db)
            .fontSize(12).fontColor(0x34d399).layoutWeight(1)
          Text('断开')
            .fontSize(11).fontColor(0xf87171)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(0x252933).borderRadius(4)
            .onClick(() => {
              PgService.close()
              this.connected = false
              this.out = ''
            })
        }
        .width('100%')
        TextInput({ placeholder: 'SQL,如 SELECT version();', text: this.sql })
          .fontSize(12).fontColor(0xe6e8ed).backgroundColor(0x1f222b).borderRadius(6)
          .onChange((v: string) => {
            this.sql = v
          })
          .onSubmit(() => this.doExec())
        Row({ space: 6 }) {
          ForEach(['SELECT version();', '\\l', 'SELECT 1;'], (q: string) => {
            Text(q)
              .fontSize(10).fontColor(0x9ea3ae)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(0x1f222b).borderRadius(4)
              .onClick(() => {
                this.sql = q
                this.doExec()
              })
          }, (q: string) => q)
        }
        .width('100%')
      }
      Scroll() {
        Text(this.out === '' ? ' ' : this.out)
          .fontSize(11).fontColor(0xe6e8ed).fontFamily('monospace')
          .width('100%').textAlign(TextAlign.Start)
      }
      .layoutWeight(1).width('100%')
      .backgroundColor(0x14171d).borderRadius(6).padding(8)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .padding(14)
    .backgroundColor(0x191c24)
    .alignItems(HorizontalAlign.Start)
  }
}
