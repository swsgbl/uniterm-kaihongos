# uniterm KaihongOS 桌面版适配设计书（阶段一：分析与选型）

日期：2026-09-20 | 状态：待编排者审核 | 作者：执行工程师（hmh）

---

## ① 上游架构摘要

上游 uniterm（D:\uniterm\upstream，Apache-2.0）是 **Wails v3（Go 后端 + WebView 前端）** 桌面应用：

| 层 | 技术 | 职责 |
|---|---|---|
| 前端 | Vue 3 + Pinia + Element Plus + **xterm.js 6** + CodeMirror 6 | 全部 UI：连接树、Tab/面板布局、终端渲染、SFTP 双栏、设置、AI 侧栏 |
| 桥接 | Wails bindings（`frontend/wailsjs/go/main/App.js`） | 前端 → Go 同步 RPC（约 **270 个方法**，见 App.d.ts） |
| 事件 | Wails Events | Go → 前端：`session:data` / `session:binary` / `session:status` / `store:connections:changed` / `transfer:*` |
| 后端 Go | `backend/session`（40+ 会话类型）、`backend/store`（JSON 存储+凭据加密）、`backend/importer`（10 种格式导入）、credentials/sync/k8s/container | **全部协议实现**（SSH 用 `golang.org/x/crypto/ssh`）、PTY、文件传输、监控 |

关键事实（决定适配策略）：
- 前端渲染完全依赖**浏览器 API**（xterm.js DOM/Canvas、CodeMirror、Element Plus DOM），在 ArkUI 上**不可运行**，只能重写 UI 层。
- 前端中**可复用的是纯逻辑代码**：类型定义（types/*.ts）、工具（quickConnect、terminalSanitize、base64、i18n）、业务规则（connectionLauncher 的连接编排逻辑可翻译成 ArkTS）。
- 后端 Go 代码**逻辑可参考**，二进制不可进 HAP（见 ③c）。

### SSH 会话前后端接口面（实测源码提取）

RPC（App.d.ts 实证）：
```
CreateSession(type:'ssh', config:ConnectionConfig) → SessionInfo{id,type,title,status}
SessionStart(id, config)            // 前端量好 cols/rows 后才真正 Connect（避免 80x24 抖动）
SessionWrite(id, s) / SessionWriteBinary(id, base64)
SessionResize(id, cols, rows)
CloseSession(id) / ListSessions() → SessionInfo[]
TestConnection(config) → string     // 连通性测试
LoadConnections/SaveConnections(ConnectionStoreData)
```
事件（app_terminal.go:163-357 实证）：
```
session:data    {id, data:string}          // 终端输出（文本）
session:binary  {id, data:base64}          // 二进制（zmodem 等）
session:status  {id, status:'connecting'|'connected'|'disconnected'|'error', remoteOS?}
store:connections:changed                  // 导入/同步后刷新
```
数据流：xterm.js onData → SessionWrite → Go stdin；Go stdout → session:data → xterm.write。

---

## ② 数据模型（连接配置 JSON schema，实测提取）

**存储文件 `connections.json`**（backend/store/connection_store.go）：
```json
{
  "groups": [ { "id": "g-1", "name": "生产环境", "parentId": null } ],
  "connections": [
    {
      "id": "c-001", "name": "web-01", "remark": "nginx",
      "type": "ssh", "host": "192.168.1.10", "port": 22,
      "user": "root", "authType": "password",
      "password": "enc:v1:AAAA…",       // 有 PasswordStore 时强制加密；无则拒存明文(fail-closed)
      "groupId": "g-1",
      "encoding": "utf-8", "backspaceKey": "del",
      "initialCols": 120, "initialRows": 32,
      "postLoginScript": "", "logOnConnect": false,
      "tunnelSSHConnId": "", "proxyId": ""
    },
    { "id": "c-002", "type": "ssh", "authType": "keyText",
      "keyContent": "enc:v1:…(与密码同构加密)", "keyPath": "" },
    { "id": "c-003", "type": "ssh", "authType": "identity", "identityId": "i-1" }
  ]
}
```
`authType` 全集：password / key(路径) / keyText(内联 PEM) / identity(引用身份库) / agent / kerberos / apikey。
SSH 核心字段：`host, port, user, authType, password, keyPath, keyContent, identityId, groupId, encoding, backspaceKey(del|bs|vt220), postLoginScript, postLoginExpectSteps[], tunnelSSHConnId, proxyId, initialCols/Rows, x11Forwarding, agentForwarding, shellIntegration, logOnConnect`。共 **25+ 类型、90+ 字段**；KaihongOS 版 M1 只需 SSH 子集 + 预留扩展。

**身份库 identities.json**：`{identities:[{id,name,username,authType:'password'|'key'|'keyText',password?,keyPath?,keyContent?}]}`

**导出格式 .utm**（backend/importer/uniterm.go，M1 必须兼容导入）：
```json
{ "format": "uniterm", "version": 1,
  "encrypted": false,
  "kdf": { "algo": "PBKDF2-SHA256", "iterations": 210000, "salt": "…" },   // 仅加密时有
  "groups": [...], "connections": [...] }   // 内嵌 ConnectionStoreData
```
密码用 PBKDF2（210k 迭代）+ AES 加密，`enc:v1:` 前缀。导入器还支持 Xshell/SecureCRT/MobaXterm/WindTerm/OpenSSH/DBeaver 等 10 种（KaihongOS 版 M1 只做 uniterm 原生两种：connections.json 与 .utm 明文；加密 .utm 列入 M3）。

---

## ③ SSH 实现路线对比与推荐

### 候选 a) 纯 ArkTS 实现 SSH2 协议栈（@ohos.net.socket + cryptoFramework）
- 可行性：**理论可行，工程量极大**。SSH2 = 版本协商/KEX(ecc curve25519 等)/cipher(chacha20/aes-gcm)/HMAC/认证/通道，全要手写。MQTT-on-ArkTS 有先例但协议复杂度低一个量级。
- 工作量：**3-6 人月**起步，且长期维护密码学正确性风险高。
- 风险：cryptoFramework 对 Ed25519 签名/PBKDF2/bcrypt 等 SSH 所需原语覆盖不全，缺的要在 ArkTS 软实现（性能+安全双重风险）。
- 结论：**否决**（除非无替代方案）。

### 候选 b) TPC/ohpm 现成 SSH 库 ✅
实测证据（2026-09-20 检索）：
- `ohpm info @ohos/ssh2`、`ssh2` → **404 NOTFOUND**（中心仓无纯 TS SSH 库）。
- **`@ohos/libssh` v1.0.4 存在**：OpenHarmony-TPC 官方孵化（openharmony-tpc-incubate/ohos_ssh，gitcode.com/openharmony-tpc/openharmony_tpc_samples/tree/master/ohos_ssh），基于 **libssh-0.11.1 C++ 库**封装，支持 **SSH 客户端 + SFTP**，HAR 分发，LGPL-2.1，8 个版本，6 个月前仍活跃发布。
- 先例佐证：Tera Term 的鸿蒙 PC 移植（ohso_teraterm）即采用「ArkTS/ArkUI PC 壳 + C++ native core」路线并已跑通终端连接。
- 可行性：**高**。HAR 直接 ohpm install，NAPI 调 C 层，协议栈成熟（libssh 广泛用于生产）。
- 工作量：**低-中**（集成 + NAPI 封装适配 + 终端 UI 重写占大头）。
- 风险：**中**——① LGPL-2.1 合规（HAR 若为动态链接共享、仅 API 调用，闭源宿主可行，发布前需法务确认；必要时评估 libssh 商业授权）；② 该库面向手机 API 为主，x86_64/API24 需实测；③ SFTP/认证方法覆盖面需 M1 期间 PoC 验证。

### 候选 c) Go 后端交叉编译为设备侧独立进程 + 本地通信
- 交叉编译：Go **无官方 GOOS=ohos**（1.23 起仅社区 fork 支持），只能 GOOS=linux/musl 静态编译赌 ABI 兼容；uniterm 后端还含 PTY/Win32 依赖，裁剪成本高。
- 沙箱：**OHOS 应用沙箱无公开 API 允许 HAP spawn/连接外部进程**——appspawn 不对三方应用开放 fork/exec；进程间通信亦无对外通道。无法持久驻留、无法随应用分发安装（需 root/hdc 手工放置）。
- 结论：**否决**（技术不可行于标准应用模型；仅 root 玩具方案）。

### 推荐路线（唯一推荐，非“都可以”）
> **HAP(ArkTS/ArkUI) 壳 + `@ohos/libssh`(HAR, NAPI) 作 SSH 引擎，进程内集成；Go 后端仅作逻辑参考、不移植二进制。**
> 可行性=高（TPC 官方库+成熟 libssh+先例）；工作量=中（集中在 ArkUI 重写与 NAPI 封装）；风险=中且可控（LGPL 合规 + x86_64 实测，均在 M1 PoC 消解）。若 M1 PoC 证伪（如 x86_64 编译不过），回退顺序：b') 直接用 libssh C 源码自建 native 模块（同为 LGPL，工程量+2 周）→ a) 纯 TS（最后手段）。

---

## ④ 总体架构（文字版）

```
┌─ HAP: com.khds.uniterm (entry HAP, x86_64, API24) ──────────────┐
│ ArkUI 层(ArkTS)                                                  │
│  ├ pages: 连接管理器(侧栏树+CRUD+导入) / 终端(自研渲染) / 设置      │
│  ├ stores: ConnectionStore / SessionStore (状态管理)              │
│  └ utils: 从上游移植 quickConnect/terminalSanitize/base64/i18n    │
│ 服务层(ArkTS, 对应上游 App.go)                                    │
│  ├ SessionService: Create/Write/Resize/Close + emit(i18n/EventHub)│
│  │   事件: session:data|status|binary → 终端组件                  │
│  └ ConnectionRepo: connections.json 读写 + enc:v1 兼容 + .utm 导入│
│ Native 层                                                         │
│  └ @ohos/libssh HAR (libssh 0.11.1): 连接/认证(password,key,keyText)│
│     /shell 通道 PTY resize/SFTP(后续里程碑)                        │
│ 持久层: 沙箱 files/connections.json (格式=上游兼容)                │
│      + HUKS/Asset 存主密钥(对应上游 keychain/master-password)      │
└──────────────────────────────────────────────────────────────────┘
目标机: KaihongOS 5.0.2.57 (OH API24, x86_64, 桌面形态, QEMU)
```

---

## ⑤ 里程碑 M1–M4（验收方式统一：hdc 安装 → 真机 UI 截图 → 功能点核验）

### M1 连接管理器（含路线 PoC）— 预计 2 周
交付物：
1. 工程脚手架（hvigor 命令行可构建、签名、装 VM）。
2. 主机 CRUD + 分组（增删改查、拖拽或菜单分组）UI，数据落 connections.json（schema 兼容上游）。
3. 导入：原版 connections.json（明文）与 .utm（明文）。
4. **PoC：@ohos/libssh 在 x86_64/API24 上真连一台 sshd 并取回 banner**（风险前置消解）。
验收标准（机检）：
- [ ] `hdc install` 成功且启动无 crash（hilog 无 FATAL）。
- [ ] 截图核验：新建主机表单、保存后列表出现该主机、分组显示正确。
- [ ] push 一份含 N 主机/M 分组的 connections.json，重启应用后列表数量一致（hilog 打印计数=文件计数）。
- [ ] 导入 .utm 后列表条数=文件条数，字段（host/port/user）抽查一致。
- [ ] PoC 日志：`ssh poc connected: SSH-2.0-OpenSSH_x.x`（hilog grep）。
- 若 PoC 失败 → 触发回退路线 b'，里程碑顺延 2 周。

### M2 SSH 终端最小可用 — 预计 3 周
交付物：终端页（自研 ArkTS 终端渲染组件：等宽字体、光标、滚动、基本 ANSI 颜色）、密码/keyText 认证、SessionService 全接口、resize、断线状态提示。
验收：
- [ ] 从连接管理器点主机 → 连接 → 屏幕出现远端 shell 提示符（截图）。
- [ ] 输入 `echo UT_OK_$$` 回显 UT_OK（截图 + hilog session:data 证据）。
- [ ] `stty size` 输出= 窗口实际列行（resize 生效）。
- [ ] 断网/杀 sshd → 界面呈 disconnected 状态（截图 + 事件日志）。
- [ ] 密码错误 → 报错可重试，不 crash。

### M3 生产可用强化 — 预计 3 周
交付物：enc:v1 密码加密存储（HUKS 主密钥，兼容上游文件互导）、身份库 identities、GBK 等编码、backspaceKey 三模式、keepalive、最近连接/收藏、加密 .utm 导入导出、SFTP 浏览（若 libssh 封装支持）。
验收：加密存储落盘抽查无明文；加密 .utm 往返导入字段一致；keepalive 30 分钟不断线（hilog 时间戳）；SFTP 列目录截图；编码为 GBK 的主机中文不乱码（截图）。

### M4 签名发布件 + 端到端验收 — 预计 1 周
交付物：正式签名 HAP（release profile）、安装说明、端到端演示脚本。
验收：
- [ ] 签名 HAP `hdc install` 到目标 VM，冷启动 ≤ 3s（hilog 时间差）。
- [ ] 端到端：导入配置 → 连接 → 跑命令 → 退出 → 重连，全程仅用户输入无开发机干预（录屏 + 截图序列）。
- [ ] 连续 1 小时会话无 FATAL/内存泄漏（hilog 采样 RSS）。
- [ ] 卸载重装数据可恢复（导入备份）。

---

## ⑥ 构建链路记录（本机实测，未构建产品代码）

| 工具 | 路径 | 版本 |
|---|---|---|
| hvigorw | `C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat` | DevEco Studio 自带 |
| ohpm | `C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin\ohpm.bat` | 可用（已实测联网检索） |
| hdc | `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe` | 3.2.0f |
| SDK | `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony` | **API 26**（oh-uni-package.json 实测），ets/native/toolchains 齐全 |
| 设备 | hdc -t 127.0.0.1:5555 | KaihongOS emulator 6.1.0.117，**API 24**，x86_64（param get 实测） |

**SDK(API26) vs 设备(API24) 差异应对**：build-profile.json5 中 `compileSdkVersion: 26`（本地 SDK）、`compatibleSdkVersion / targetSdkVersion: 24`（5.0.2），即“新编译、旧兼容”；hvigor 校验允许该组合。若 M1 实际构建报兼容下限错误，备选方案：DevEco Studio → Settings → SDK 装 API24 组件（需华为账号，组件管理器下载）。
计划命令行（M1 验证）：
```bat
set PATH=C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin;C:\Program Files\Huawei\DevEco Studio\tools\node;%PATH%
cd /d D:\uniterm\kaihongos
ohpm install @ohos/libssh
hvigorw.bat assembleHap --mode module -p product=default -p buildMode=release
hdc -t 127.0.0.1:5555 install entry\build\default\outputs\default\entry-default-signed.hap
hdc -t 127.0.0.1:5555 shell aa start -a EntryAbility -b com.khds.uniterm
```
签名：调试签名走 DevEco 自动；命令行签名用 SDK `toolchains` 下 hap-sign-tool（M1 脚本化，正式签名 M4）。

---

## ⑦ 风险清单与待拍板决策点（给编排者）

**风险 Top5**：
1. **LGPL-2.1 合规**（@ohos/libssh）：若产品闭源分发，需确认 HAR 链接形态满足 LGPL，或购 libssh 商业授权（Fabrice Fontaine 组织）。→ 待拍板 D1。
2. **@ohos/libssh 的 x86_64/API24 兼容性未实测**：M1 PoC 前置消解；失败回退 b'（libssh 源码自编译，+2 周）。
3. **终端渲染性能**：自研 ArkTS 终端组件渲染高频输出（top/vim）可能掉帧——需 M2 做吞吐基准（≥2MB/s 判过线），必要时降级为 C++ 画布或限制滚动缓冲。
4. **上游协议面太大**：90+ 字段 25 类型，M1-M4 只覆盖 SSH 子集；其他协议（telnet/RDP/DB…）明确出 M4 范围，避免范围蔓延。
5. **QEMU 虚拟机环境噪声**：键盘注入/截图链路历史不稳定（IME 吞键），验收脚本须用 hdc 日志佐证而非纯 UI 断言。

**待拍板决策点**：
- D1 LGPL 合规路线（法务确认 vs 商业授权 vs 接受开源义务）。
- D2 bundleName / 应用名（暂定 com.khds.uniterm）。
- D3 M1 是否包含「测试连接」按钮（TestConnection 需 libssh PoC 提前到第 1 周）。
- D4 加密 .utm 的 PBKDF2 参数须与上游 bit 级一致（210k 迭代 SHA256），确认是否有历史样本文件可供回归。
- D5 是否需要应用内中文/英文双语（上游有 10 语言 i18n，建议 M1 只做 zh-CN）。

---
*证据文件：probe 脚本 D:\uniterm\docs\.probe_ohpm.cjs / .probe_tpc.cjs；检索时间 2026-09-20。*
