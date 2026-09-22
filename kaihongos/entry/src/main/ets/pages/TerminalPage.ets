/**
 * uniterm M2 relay-4 - Terminal page (rendered terminal + key passthrough).
 *
 * On top of relay-3b's line stream:
 *  - TermModel ANSI emulator: colors (SGR/256), cursor control, line rewrites
 *    (prompt editing via BS/EL), implicit scrollback up to 5000 lines;
 *  - rendered lines are Row{ForEach(run->Text)} spans with per-run fg/bg
 *    (incl. cursor block at the logical cursor cell), monospace concatenated;
 *  - hardware keyboard passthrough: the terminal area is focusable, focused
 *    on touch/connect; printable keys + arrows/Tab/Enter/Backspace/Ctrl+X
 *    go straight to the ssh stdin (Enter=\r, arrows=\x1b[A.., Ctrl+\x01..\x1a);
 *    the bottom input line stays as IME fallback (Chinese input etc);
 *  - status bar shows lines/bytes + last command latency for benchmarks;
 *  - only the visible window (rows+overscan) of the scrollback is snapshotted
 *    into @State winRows each poll, keeps 20000-line floods smooth.
 */
import { MeasureText, MeasureOptions, router, display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ConnRec, ConnectionStore, getSharedStore } from '../store/ConnStore';
import { SessionService, TermStats, TermView } from '../service/SessionService';
import { TermModel, TermLine, lineToSpans, SpanRun, TERM_DEFAULT_FG, TERM_DEFAULT_BG } from '../components/TermModel';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TERM_FONT_SIZE: number = 14;
const TERM_FONT_FAMILY: string = 'monospace';
const BODY_PAD: number = 8;
const WIN_OVERSCAN: number = 90; // rows above tail kept bound -> Column overflows viewport, scrollable
const POLL_MS: number = 100;

// KeyCode values (api/@ohos.multimodalInput.keyCode.d.ts, API24)
const KC_DPAD_UP: number = 2012;
const KC_DPAD_DOWN: number = 2013;
const KC_DPAD_LEFT: number = 2014;
const KC_DPAD_RIGHT: number = 2015;
const KC_DPAD_CENTER: number = 2016;
const KC_A: number = 2017;
const KC_Z: number = 2042;
const KC_TAB: number = 2049;
const KC_ENTER: number = 2054;
const KC_DEL: number = 2055;
const KC_GRAVE: number = 2056;
const KC_ESCAPE: number = 2070;
const KC_MOVE_HOME: number = 2081;
const KC_MOVE_END: number = 2082;
const KC_PAGE_UP: number = 2068;
const KC_PAGE_DOWN: number = 2069;
const KC_BACKSLASH: number = 2061;

interface Dims {
  cols: number;
  rows: number;
  charWidth: number;
}

@Entry
@Component
struct TerminalPage {
  @StorageProp('ut.term.status') storageStatus: string = 'idle';
  @StorageProp('ut.term.reason') storageReason: string = '';
  @State title: string = '';
  @State input: string = '';
  @State cols: number = 80;
  @State rows: number = 24;
  @State measureNote: string = '';
  @State statText: string = '';
  @State passthrough: boolean = true;
  @State focused: boolean = false;
  @State winTop: number = 0; // first bound scrollback row index
  @State winSize: number = 60; // number of bound rows
  @State winRows: TermLine[] = []; // bound window snapshot (state!)
  @State tick: number = 0; // bump to force span re-render (cursor moves)
  private view: TermBufferView = new TermBufferView();
  private model: TermModel = new TermModel(80, 24);
  private scroller: Scroller = new Scroller();
  private pollTimer: number = -1;
  private resizeTimer: number = -1;
  private opened: boolean = false;
  private connId: string = '';
  private followTail: boolean = true;

  aboutToAppear(): void {
    this.view.attach(this.model);
    SessionService.attachView(this.view);
    const p = router.getParams() as Record<string, string>;
    if (p !== undefined && p !== null) {
      const cid = p['connId'];
      if (typeof cid === 'string') {
        this.connId = cid;
      }
    }
    const ctx = getContext(this) as common.UIAbilityContext;
    // M3: use the SHARED store (has the unlocked CredentialManager attached,
    // so keyContent/password are decrypted in memory). Do NOT re-load() here:
    // the disk copy holds enc:v1 ciphertext which would overwrite the
    // decrypted in-memory values.
    const store = getSharedStore();
    if (store === null) {
      AppStorage.setOrCreate('ut.term.status', 'error');
      AppStorage.setOrCreate('ut.term.reason', 'store not ready (open the connection list first)');
      return;
    }
    let conn: ConnRec | null = null;
    for (let i = 0; i < store.connections.length; i++) {
      if (store.connections[i].id === this.connId) {
        conn = store.connections[i];
      }
    }
    if (conn === null) {
      this.title = 'unknown';
      AppStorage.setOrCreate('ut.term.status', 'error');
      AppStorage.setOrCreate('ut.term.reason', 'conn not found: ' + this.connId);
      return;
    }
    this.title = conn.user + '@' + conn.host + ':' + conn.port.toString();
    const m = this.measureDims();
    this.cols = m.cols;
    this.rows = m.rows;
    this.model.resize(this.cols, this.rows);
    this.winSize = this.rows + 2 * WIN_OVERSCAN;
    this.measureNote = 'measured ' + m.cols + 'x' + m.rows;
    const connId = conn.id;
    const postScript = conn.postLoginScript;
    SessionService.connect(conn, this.cols, this.rows).then((id: number) => {
      this.opened = true;
      // M3-3a: stamp lastUsedAt for the recents section (persist best-effort)
      try {
        const st = getSharedStore();
        if (st !== null) {
          st.markUsed(connId);
        }
      } catch (e) {
        hilog.warn(0x0110, 'uniterm.term', 'markUsed failed: %{public}s', JSON.stringify(e));
      }
      // M3-3a: post-login script - send after the banner settles (~1.2s)
      if (postScript !== null && postScript.length > 0) {
        setTimeout(() => {
          try {
            const n = SessionService.write(postScript + '\r');
            hilog.info(0x0110, 'uniterm.term', 'postLoginScript sent %{public}d bytes', n);
          } catch (e2) {
            hilog.warn(0x0110, 'uniterm.term', 'postLoginScript failed: %{public}s', JSON.stringify(e2));
          }
        }, 1200);
      }
    }).catch((e: Object) => {
      // M3 relay-2d: connect() throws for missing identities / bad args BEFORE
      // publishing status - surface the reason here or the user sees nothing.
      const msg = e instanceof Error ? e.message : JSON.stringify(e);
      AppStorage.setOrCreate('ut.term.status', 'error');
      AppStorage.setOrCreate('ut.term.reason', msg);
      hilog.error(0x0110, 'uniterm.term', 'connect rejected: %{public}s', msg);
    });
    this.startPoll();
  }

  aboutToDisappear(): void {
    this.stopPoll();
    if (this.resizeTimer >= 0) {
      clearTimeout(this.resizeTimer);
      this.resizeTimer = -1;
    }
    if (this.opened) {
      SessionService.close();
      this.opened = false;
    }
    SessionService.attachView(null);
  }

  private startPoll(): void {
    this.pollTimer = setInterval(() => {
      this.drainTick();
    }, POLL_MS);
  }

  private stopPoll(): void {
    if (this.pollTimer >= 0) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
    }
  }

  /** Poll: merge ssh bytes into the model, update window + stats. */
  private drainTick(): void {
    const grew = this.view.drain();
    const st = SessionService.stats();
    this.statText = st.lines + ' lines  ' + st.bytes + 'B  ' + st.chunks + ' chunks'
      + (st.lastCmdMs >= 0 ? '  last ' + st.lastCmdMs + 'ms' : '');
    if (grew && this.followTail) {
      this.tick++;
      this.refreshWindow(true);
    } else if (grew) {
      this.tick++;
      const total = this.model.lines.length;
      this.winTop = Math.max(0, Math.min(this.winTop, total - 1));
      this.refreshWindow(false);
    }
  }

  /** Re-snapshot the bound window from the model into @State winRows. */
  private refreshWindow(follow: boolean): void {
    const total = this.model.lines.length;
    if (follow || this.followTail) {
      this.winTop = Math.max(0, total - this.winSize);
    }
    const top = Math.min(this.winTop, Math.max(0, total - 1));
    const end = Math.min(total, top + this.winSize);
    this.winRows = this.model.lines.slice(top, end);
  }

  private measureDims(): Dims {
    let density = 3;
    try {
      const dd = display.getDefaultDisplaySync();
      density = dd.densityPixels;
    } catch (e) {
      // keep 3
    }
    let charW = TERM_FONT_SIZE * 0.6;
    let lineH = TERM_FONT_SIZE * 1.45;
    try {
      const probe = 'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM';
      const opts: MeasureOptions = {
        textContent: probe,
        fontSize: TERM_FONT_SIZE,
        fontFamily: TERM_FONT_FAMILY
      };
      const w = MeasureText.measureText(opts);
      if (w > 0) {
        charW = w / 40 / density;
      }
      const sz = MeasureText.measureTextSize(opts);
      const hh = sz.height as number;
      if (hh > 0) {
        lineH = hh;
      }
    } catch (e) {
      // keep estimates
    }
    let bodyW = 300;
    let bodyH = 500;
    try {
      const d = display.getDefaultDisplaySync();
      bodyW = (d.width / density) - 2 * BODY_PAD;
      bodyH = (d.height / density) - 2 * BODY_PAD - 56 /* header */ - 60 /* footer */;
    } catch (e) {
      // keep estimates
    }
    const cols = Math.max(20, Math.floor(bodyW / charW));
    const rows = Math.max(6, Math.floor(bodyH / lineH));
    const out: Dims = { cols: cols, rows: rows, charWidth: charW };
    return out;
  }

  private termViewportH: number = 1000;

  private pxPerRowDensity(): number {
    try {
      const d = display.getDefaultDisplaySync();
      return d.densityPixels;
    } catch (e) {
      return 3;
    }
  }

  private onBodyArea(w: number, h: number): void {
    this.termViewportH = h;
    this.termViewportH = h;
    let density = 1;
    try {
      const d = display.getDefaultDisplaySync();
      density = d.densityPixels;
    } catch (e) {
      // keep 1
    }
    let charW = TERM_FONT_SIZE * 0.6;
    try {
      const probe = 'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM';
      const opts: MeasureOptions = {
        textContent: probe,
        fontSize: TERM_FONT_SIZE,
        fontFamily: TERM_FONT_FAMILY
      };
      const mw = MeasureText.measureText(opts);
      if (mw > 0) {
        charW = mw / 40 / density;
      }
    } catch (e) {
      // keep estimate
    }
    const cols = Math.max(20, Math.floor((w - 2 * BODY_PAD) / charW));
    const rows = Math.max(6, Math.floor((h - 2 * BODY_PAD) / (TERM_FONT_SIZE * 1.45)));
    if (cols === this.cols && rows === this.rows) {
      return;
    }
    this.cols = cols;
    this.rows = rows;
    this.winSize = rows + 2 * WIN_OVERSCAN;
    this.model.resize(cols, rows);
    this.measureNote = 'area ' + cols + 'x' + rows;
    if (this.resizeTimer >= 0) {
      clearTimeout(this.resizeTimer);
    }
    this.resizeTimer = setTimeout(() => {
      this.resizeTimer = -1;
      if (this.opened) {
        SessionService.resize(this.cols, this.rows);
      }
    }, 300);
  }

  private send(): void {
    const text = this.input + '\r';
    SessionService.write(text);
    this.input = '';
  }

  /** Hardware-key -> terminal byte mapping. Returns the string to write. */
  private mapKey(code: number, ev: KeyEvent): string {
    let ctrl = false;
    try {
      if (ev.getModifierKeyState !== undefined && ev.getModifierKeyState(['Ctrl'])) {
        ctrl = true;
      }
    } catch (e) {
      // modifier probe unsupported: fall through plain
    }
    if (ctrl) {
      if (code >= KC_A && code <= KC_Z) {
        return String.fromCharCode(code - KC_A + 1); // \x01..\x1a (Ctrl+C etc)
      }
      if (code === KC_BACKSLASH) {
        return String.fromCharCode(28); // Ctrl+backslash
      }
      if (code === KC_GRAVE) {
        return String.fromCharCode(0); // Ctrl+Space / NUL
      }
      return '';
    }
    switch (code) {
      case KC_ENTER:
      case KC_DPAD_CENTER:
        return '\r';
      case KC_DEL:
        return '\x7f';
      case KC_TAB:
        return '\t';
      case KC_ESCAPE:
        return '\x1b';
      case KC_DPAD_UP:
        return '\x1b[A';
      case KC_DPAD_DOWN:
        return '\x1b[B';
      case KC_DPAD_RIGHT:
        return '\x1b[C';
      case KC_DPAD_LEFT:
        return '\x1b[D';
      case KC_MOVE_HOME:
        return '\x1b[H';
      case KC_MOVE_END:
        return '\x1b[F';
      case KC_PAGE_UP:
        return '\x1b[5~';
      case KC_PAGE_DOWN:
        return '\x1b[6~';
      default:
        break;
    }
    // printable single chars: keyText covers ASCII printables incl. space
    const t = ev.keyText;
    if (t !== undefined && t !== null && t.length === 1) {
      const c = t.charCodeAt(0);
      if (c >= 0x20 && c < 0x7f) {
        return t;
      }
    }
    return '';
  }

  private onTermKey(ev: KeyEvent): boolean {
    if (ev.type !== KeyType.Down) {
      return false;
    }
    if (!this.passthrough || !this.opened) {
      return false;
    }
    const s = this.mapKey(ev.keyCode, ev);
    if (s.length > 0) {
      SessionService.write(s);
      return true; // consumed: no focus navigation side effect
    }
    return false;
  }

  @Builder
  StatusBadge() {
    Text(this.badgeText())
      .fontSize(12)
      .fontColor(Color.White)
      .backgroundColor(this.badgeColor())
      .borderRadius(8)
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
  }

  private badgeText(): string {
    const s = this.storageStatus;
    if (s === 'connected') {
      return 'connected';
    }
    if (s === 'connecting') {
      return 'connecting';
    }
    if (s === 'error') {
      return 'error';
    }
    if (s === 'disconnected') {
      return 'disconnected';
    }
    return 'idle';
  }

  private badgeColor(): ResourceColor {
    const s = this.storageStatus;
    if (s === 'connected') {
      return 0x2f9e6e;
    }
    if (s === 'connecting') {
      return 0xe6a23c;
    }
    if (s === 'error') {
      return 0xf56c6c;
    }
    return 0x909399;
  }

  @Builder
  TermLineView(line: TermLine, rowIdx: number) {
    Row() {
      ForEach(lineToSpans(line, this.cursorXFor(rowIdx), this.cursorVisibleFor(rowIdx)),
        (run: SpanRun, idx: number) => {
          Text(run.text.replace(/ /g, '\u00a0'))
            .fontSize(TERM_FONT_SIZE)
            .fontFamily(TERM_FONT_FAMILY)
            .fontColor(run.fg)
            .fontWeight(run.bold ? FontWeight.Bold : FontWeight.Normal)
            .backgroundColor(run.bg !== null ? run.bg : Color.Transparent)
        }, (run: SpanRun, idx: number) => rowIdx.toString() + ':' + idx.toString() + ':'
          + run.text.length + ':' + run.fg + ':' + (run.bg ?? '-'))
    }
    .height(TERM_FONT_SIZE * 1.5)
    .width('100%')
  }

  private cursorXFor(rowIdx: number): number {
    if (!this.model.cursor.visible) {
      return -1;
    }
    const cy = this.model.lines.length - this.model.rows + this.model.cursor.y;
    if (rowIdx === cy) {
      return this.model.cursor.x;
    }
    return -1;
  }

  private cursorVisibleFor(rowIdx: number): boolean {
    return this.focused;
  }

  build() {
    Column() {
      // header
      Column() {
        Row({ space: 8 }) {
          Column() {
            Text(this.title)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .maxLines(1)
            Text(this.cols.toString() + 'x' + this.rows.toString() + '  ' + this.measureNote
              + (this.focused ? '  [key-passthrough]' : ''))
              .fontSize(11)
              .fontColor(0x9aa5b8)
              .maxLines(1)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          this.StatusBadge()

          Button('SFTP')
            .fontSize(13)
            .backgroundColor(0x2c6fbb)
            .enabled(this.storageStatus === 'connected')
            .onClick(() => {
              router.pushUrl({ url: 'pages/SftpPanel', params: { title: this.title } });
            })
          Button('close')
            .fontSize(13)
            .backgroundColor(0x8a2f3d)
            .onClick(() => {
              SessionService.close();
              router.back();
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })

        Text(this.statText)
          .fontSize(11)
          .fontColor(0x8a93a5)
          .width('100%')
          .padding({ left: 12, right: 12, bottom: 4 })

        if (this.storageStatus === 'error' && this.storageReason.length > 0) {
          Text('error: ' + this.storageReason)
            .fontSize(12)
            .fontColor(0xffb4b4)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .padding({ left: 12, right: 12, bottom: 6 })
        }
      }
      .width('100%')
      .backgroundColor(0x1f2d3d)

      // terminal body: focusable surface for hardware key passthrough
      Scroll(this.scroller) {
        Column() {
          ForEach(this.winRows, (line: TermLine, idx: number) => {
            this.TermLineView(line, this.winTop + idx)
          }, (line: TermLine, idx: number) => (this.winTop + idx).toString() + ':' + line.rev.toString() + ':'
            + this.tick.toString())
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(BODY_PAD)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(TERM_DEFAULT_BG)
      .align(Alignment.Bottom)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.None)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .onClick(() => {
        this.focused = true;
        this.tick++;
      })
      .onKeyEvent((ev: KeyEvent) => {
        return this.onTermKey(ev);
      })
      .onAreaChange((oldArea: Area, newArea: Area) => {
        const w = newArea.width as number;
        const h = newArea.height as number;
        this.onBodyArea(w, h);
      })

      // footer: IME fallback input line + passthrough toggle
      Row({ space: 8 }) {
        Toggle({ type: ToggleType.Switch, isOn: this.passthrough })
          .onChange((on: boolean) => {
            this.passthrough = on;
          })
        Text('PT')
          .fontSize(12)
          .fontColor(this.passthrough ? 0x2f9e6e : 0x8a93a5)
        TextInput({ placeholder: 'input + Enter...', text: this.input })
          .layoutWeight(1)
          .fontSize(14)
          .fontFamily(TERM_FONT_FAMILY)
          .backgroundColor(0x161b22)
          .fontColor(TERM_DEFAULT_FG)
          .placeholderColor(0x6b7280)
          .onChange((v: string) => {
            this.input = v;
          })
          .onSubmit(() => {
            this.send();
          })
        Button('send')
          .fontSize(14)
          .backgroundColor(0x2f9e6e)
          .onClick(() => {
            this.send();
          })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 10 })
      .backgroundColor(0x1f2d3d)
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * Bridge from SessionService events to the TermModel. Runs inside the tsfn
 * JS callback (main thread), so attach/drain are same-thread with the page.
 */
class TermBufferView implements TermView {
  private model: TermModel | null = null;
  private dirty: boolean = false;

  attach(m: TermModel): void {
    this.model = m;
  }

  accept(raw: string): void {
    if (this.model !== null && raw.length > 0) {
      this.model.feed(raw);
      this.dirty = true;
    }
  }

  drain(): boolean {
    const d = this.dirty;
    this.dirty = false;
    return d;
  }
}
