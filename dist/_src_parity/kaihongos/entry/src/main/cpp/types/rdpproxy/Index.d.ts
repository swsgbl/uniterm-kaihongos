export declare class RdpNapi {
  constructor();
  rdpConnect(host: string, port: number, user: string, password: string, w: number, h: number,
    onFrame: (x: number, y: number, w: number, h: number, ab: ArrayBuffer) => void): void;
  rdpDisconnect(): void;
  rdpIsRunning(): boolean;
}
