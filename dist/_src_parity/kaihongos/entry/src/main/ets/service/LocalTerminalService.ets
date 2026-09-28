// 本地终端服务:liblocalpty.so(/bin/sh PTY)
import { LocalPtyNapi } from 'liblocalpty.so';
import { SessionService } from './SessionService';

export class LocalTerminalService {
  private static mod: LocalPtyNapi | null = null
  private static opened: boolean = false

  static active(): boolean {
    return LocalTerminalService.opened
  }

  static ensureLib(): LocalPtyNapi | null {
    if (LocalTerminalService.mod !== null) {
      return LocalTerminalService.mod
    }
    LocalTerminalService.mod = new LocalPtyNapi()
    return LocalTerminalService.mod
  }

  static open(cols: number, rows: number): boolean {
    const m = LocalTerminalService.ensureLib()
    if (m === null) {
      return false
    }
    if (LocalTerminalService.opened) {
      return true
    }
    m.ptyOpen(cols, rows, (text: string): void => {
      SessionService.feedExternal(text)
    })
    LocalTerminalService.opened = true
    return true
  }

  static write(text: string): void {
    const m = LocalTerminalService.mod
    if (m !== null && LocalTerminalService.opened) {
      m.ptyWrite(text)
    }
  }

  static resize(cols: number, rows: number): void {
    const m = LocalTerminalService.mod
    if (m !== null && LocalTerminalService.opened) {
      m.ptyResize(cols, rows)
    }
  }

  static close(): void {
    const m = LocalTerminalService.mod
    if (m !== null && LocalTerminalService.opened) {
      m.ptyClose()
      LocalTerminalService.opened = false
    }
  }
}
