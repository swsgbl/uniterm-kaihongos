# uniTerm KaihongOS — 官方一比一复刻(全协议版)

对标官方 uniterm.net(GitHub: ys-ll/uniterm)的 KaihongOS/OpenHarmony x86_64 移植。
本 release 为全量源码快照,主文件为 `uniterm-kaihongos-src.zip`(304 文件)。

## 协议层(100% 对齐官方)

| 协议 | 实现 |
|---|---|
| SSH/SFTP | libssh HAR(NAPI) |
| Telnet | 纯 TS(IAC 协商过滤) |
| Raw TCP | 纯 TS socket |
| 本地终端 | forkpty+/bin/sh NAPI C++(liblocalpty.so) |
| Redis | RESP 纯 TS |
| PostgreSQL | wire v3 + md5 纯 TS |
| MySQL | handshake + native_password(SHA1) 纯 TS |
| Kubernetes | REST + Bearer Token |
| VNC | RFB 3.8 + DES challenge-response 纯 TS + PixelMap |
| RDP | FreerDP 3.9 交叉编译静态库 NAPI 桥(librdpproxy.so) |
| SPICE | REDQ 握手 + RSA 票据 + DISPLAY 通道 纯 TS |

## 功能层

- 官方外壳布局:38px 顶栏 TabsList + 280px 侧栏 7 视图 + StartTab + 三主题(#14171d/#22d3ee)
- AI 侧栏:Anthropic/OpenAI 双协议真实对话 + 终端执行 Agent(官方四确认模式)
- 监控(/proc 实时)/文件树/快捷命令/历史/个性化/设置页/分屏
- 连接管理 + .utm 互通 + 凭据加密

## 构建

见 `prompts/028-official-parity-audit.md`(pack_hap → fix-hap 补 so → hap-sign-tool 重签 → bm install)。
