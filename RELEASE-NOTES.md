# uniTerm KaihongOS — v1.1.0(实证版)

对标官方 uniterm(GitHub: ys-ll/uniterm)的 KaihongOS/OpenHarmony x86_64 移植。
本版本起,能力清单**只列经过真机/虚拟机端到端验收的功能**,验收证据存于 `evidence/M4`、`evidence/M5`(含各 relay 深度验收记录)。

## 已实证能力(12 项)

| # | 能力 | 实现方式 | 验收要点 |
|---|---|---|---|
| 1 | SSH 远程终端 | @ohos/libssh HAR(NAPI) | 密码/keyText/身份库三认证;WSL 靶机 10.0.2.2:2222 真连回显交互 |
| 2 | SFTP 文件传输 | 复用终端 SSH 会话 | 远程目录浏览/上传/下载 |
| 3 | 本地终端 | forkpty + /bin/sh NAPI C++(liblocalpty.so) | VM 内 shell 交互、exit 退出、pty 回显 |
| 4 | Telnet | 纯 TS(IAC 协商过滤) | WSL telnetd:2323 实连 |
| 5 | PostgreSQL | wire v3 + md5 纯 TS | WSL PG:5432 真实查询(SCRAM 场景备有预案) |
| 6 | Redis | RESP 纯 TS | WSL Redis:6379 真实读写 |
| 7 | VNC | RFB 3.8 纯 TS + PixelMap | WSL x11vnc:5900 连接并渲染画面;None 认证(DES challenge-response 未实现) |
| 8 | RDP | FreerDP 3.9 交叉编译 NAPI 桥(librdpproxy.so) | WSL xrdp:3389 登录画面级 |
| 9 | AI 侧栏 | Anthropic/OpenAI 双协议纯 TS | 真连 bigmodel(GLM)对话;终端执行 Agent |
| 10 | 系统监控 | /proc 实时采集 | CPU/内存/进程面板 |
| 11 | 连接管理 | 分组/收藏/最近 | 官方 connections.json 双向互导 |
| 12 | 凭据安全 | PBKDF2(600k)+ AES-256-GCM | 密文落盘;加密 .utm 与官方格式互认互导 |

外壳:官方同款布局(顶栏 TabsList + 侧栏 7 视图 + StartTab),dark/navy/light 三主题,浅色 token 与官方 `style.css` 对齐。

## 后续路线(未实证,不在当前能力表内)

MySQL、Kubernetes、SPICE、X11 转发、Zmodem、SSH 隧道、云端同步、容器管理等 — 待逐项按"实现→真机验收→入表"流程推进。

## 构建

见 `prompts/028-official-parity-audit.md`(pack_hap → 补 so → hap-sign-tool 重签 → bm install);VM 原生链脚本见 `evidence/M5/relay5`。
