/**
 * uniterm M1b relay-3 - "Test connection" dialog per host row.
 * Reuses the M1a PoC path: local libssh HAR -> getServerBanner(host, port).
 * Success: green "SSH-2.0-..." banner + elapsed ms.
 * Failure: red error detail (refused / timeout), never crashes the page.
 */
import { libssh } from '@ohos/libssh';
import { ConnRec } from '../store/ConnStore';

@Component
export struct TestConn {
  conn: ConnRec | null = null;
  onClose: () => void = () => {};

  @State result: string = '';
  @State ok: boolean = false;
  @State busy: boolean = false;

  aboutToAppear(): void {
    this.run();
  }

  private async run(): Promise<void> {
    const c = this.conn;
    if (c === null) {
      this.result = '内部错误: 无主机数据';
      this.ok = false;
      return;
    }
    if (c.type !== 'ssh') {
      this.result = '暂不支持连接: ' + c.type + ' 类型(仅 SSH 可测试)';
      this.ok = false;
      return;
    }
    this.busy = true;
    this.ok = false;
    this.result = '正在连接 ' + c.host + ':' + c.port.toString() + ' ...';
    const t0 = Date.now();
    try {
      const ssh = new libssh();
      const banner: string = await ssh.getServerBanner(c.host, c.port);
      const ms = Date.now() - t0;
      if (banner !== null && banner !== undefined && banner.length > 0) {
        this.ok = true;
        this.result = '✓ ' + banner + ' (' + ms.toString() + 'ms)';
      } else {
        this.result = '✗ 失败: 未取到 banner (超时/拒绝)';
      }
    } catch (e) {
      this.result = '✗ 失败: ' + JSON.stringify(e);
    } finally {
      this.busy = false;
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('测试连接')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(this.conn !== null ? this.conn.name + '  ' + this.conn.host + ':' +
        (this.conn !== null ? this.conn.port.toString() : '') : '')
        .fontSize(14)
        .fontColor(0x909399)
      Scroll() {
        Text(this.result)
          .fontSize(15)
          .fontColor(this.busy ? 0x909399 : (this.ok ? 0x2f9e6e : Color.Red))
          .padding(6)
      }
      .constraintSize({ maxHeight: 160 })
      .width('100%')
      .backgroundColor(0xF1F3F5)
      .borderRadius(8)

      if (this.busy) {
        LoadingProgress().width(28).height(28)
      }

      Row({ space: 12 }) {
        Button('重测')
          .backgroundColor(0x576b95)
          .layoutWeight(1)
          .enabled(!this.busy)
          .onClick(() => {
            this.run();
          })
        Button('关闭')
          .backgroundColor(0x909399)
          .layoutWeight(1)
          .onClick(() => {
            this.onClose();
          })
      }
      .width('100%')
    }
    .width('78%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }
}
