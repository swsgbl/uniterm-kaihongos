export declare class LocalPtyNapi {
  constructor();
  ptyOpen(cols: number, rows: number, onData: (text: string) => void): number;
  ptyWrite(text: string): number;
  ptyClose(): void;
  ptyResize(cols: number, rows: number): void;
}
