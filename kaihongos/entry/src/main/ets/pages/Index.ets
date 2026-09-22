import { ConnectionStore } from '../store/ConnStore';
import { libssh } from '@ohos/libssh';
import { ConnList } from './ConnList';

/**
 * uniTerm KaihongOS - shell page (M1b).
 * Left rail: nav to 连接管理 (M1b ConnList) and SSH PoC (M1a regression page).
 * The M1a PoC stays available for regression checks.
 */
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State pane: number = 0; // 0 = connection manager, 1 = PoC
  @State poceResult: string = '';
  @State poceBusy: boolean = false;

  build() {
    Row() {
      // left rail
      Column({ space: 4 }) {
        Text('uniTerm')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .padding({ top: 18, bottom: 14 })
        this.RailBtn('连接管理', 0)
        this.RailBtn('SSH PoC', 1)
        Blank()
        Text('M1b')
          .fontSize(11)
          .fontColor(0x8a93a5)
          .padding(8)
      }
      .width(150)
      .height('100%')
      .backgroundColor(0x1f2d3d)
      .alignItems(HorizontalAlign.Center)

      // right pane
      Column() {
        if (this.pane === 0) {
          ConnList({
            onNeedStore: (): ConnectionStore => {
              const ctx = getContext(this) as common.UIAbilityContext;
              return new ConnectionStore(ctx.filesDir);
            }
          })
        } else {
          this.PocPane()
        }
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  RailBtn(label: string, idx: number) {
    Text(label)
      .fontSize(14)
      .fontColor(this.pane === idx ? Color.White : 0x9aa5b8)
      .backgroundColor(this.pane === idx ? 0x3a516c : Color.Transparent)
      .borderRadius(6)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ top: 4 })
      .onClick(() => {
        this.pane = idx;
      })
  }

  @Builder
  PocPane() {
    Column({ space: 12 }) {
      Text('SSH PoC (M1a 回归)')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Button('SSH PoC 连接 10.0.2.2:22')
        .width('80%')
        .enabled(!this.poceBusy)
        .onClick(() => {
          this.probe('10.0.2.2', 22);
        })
      Button('失败路径测试 10.0.2.2:2222')
        .width('80%')
        .enabled(!this.poceBusy)
        .onClick(() => {
          this.probe('10.0.2.2', 2222);
        })
      Text('结果:')
        .fontSize(15)
        .alignSelf(ItemAlign.Start)
        .margin({ left: '10%' })
      Scroll() {
        Text(this.poceResult.length > 0 ? this.poceResult : '(idle)')
          .fontSize(14)
          .fontColor(this.poceResult.startsWith('FAILED') ? Color.Red : Color.Black)
          .padding(10)
      }
      .constraintSize({ maxHeight: 200 })
      .width('80%')
      .backgroundColor(0xF1F3F5)
      .borderRadius(8)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private async probe(host: string, port: number): Promise<void> {
    if (this.poceBusy) {
      return;
    }
    this.poceBusy = true;
    this.poceResult = 'connecting ' + host + ':' + port.toString() + ' ...';
    try {
      const ssh = new libssh();
      const banner: string = await ssh.getServerBanner(host, port);
      if (banner !== null && banner !== undefined && banner.length > 0) {
        this.poceResult = banner;
      } else {
        this.poceResult = 'FAILED: empty banner (timeout 5s / refused)';
      }
    } catch (e) {
      this.poceResult = 'FAILED: ' + JSON.stringify(e);
    } finally {
      this.poceBusy = false;
    }
  }
}
