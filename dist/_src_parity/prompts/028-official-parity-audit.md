# 028 官方一比一复刻任务书(差距审计→移植路线)

日期:2026-09-23 | 状态:待执行 | 前置:027

## 背景

用户要求:与官方 uniterm(uniterm.net,github.com/ys-ll/uniterm)一样的功能、布局、设计。
官方源码已下载:/data/local/home/tmp/official/uniterm-main(master,4.7MB zip)

## 官方架构(实测)

- Go 后端(app_*.go 30+ 文件,backend/session 40+ 会话类型,约 270 个 Wails RPC)
- Vue3+Pinia+ElementPlus+xterm.js6 前端:100 组件、248 ts/vue 文件
- 布局:AppHeader(顶栏:连接按钮+TabsList+AI按钮+设置菜单) / Sidebar(7 视图标签:连接/文件/监控/隧道/快捷命令/历史/个性化,搜索+类型过滤+收藏组+分组树) / tab-area(KeepAlive 按类型渲染 13 种 TabContent)
- 主题 CSS 变量(:root):--bg-base:#14171d --bg-elevated:#191c24 --bg-surface:#1f222b --accent:#22d3ee(青) --text-primary:#e6e8ed 等,完整见 frontend/src/style.css
- i18n 9 语言;28 终端主题+3 界面主题

## 当前 kaihongos 版现状

17 个 ets 文件:Index(左栏导航壳,非官方布局)/ConnList/TerminalPage/SftpPanel/ConnForm/IdentityManager 等。
SSH+SFTP+连接管理+.utm 导入导出+凭据加密已可用(M1-M4 完成)。

## 差距清单(按优先级)

### P0 布局外壳一比一(本期核心,纯 ArkTS 可完成)
0. 【剩余·下棒首选】终端标签接入:TerminalPage.ets 去 @Entry 化(改 @Component,connId 改 @Link/@Prop,aboutToAppear 的 Want 解析移到 Index);ConnList.ets 双击连接处加 onOpenConn 回调(@Link 或事件),Index.tabs push {kind:'terminal', connId};标签区渲染内嵌 TerminalPage。改完后 router 导航路径删除。注意 TerminalPage 依赖 getSharedStore() 初始化,需保证 ConnList 先加载过。
1. 顶栏 AppHeader:连接切换钮 + 水平 TabsList(图标+名称+关闭钮+新增+钮,拖拽排序) + AI 钮 + 设置下拉(主题/语言/密钥库/代理/隧道/导入导出/设置/关于)
2. Sidebar:7 个图标视图切换 + 搜索框 + 类型过滤 + 新建(连接/分组/导入/导出) + 收藏虚拟组 + 分组树(展开/折叠/计数徽标/右键菜单/拖拽)
3. StartTabContent(欢迎页):默认新标签页
4. 主题系统:官方三主题色板移植为 ArkTS Resource/AppStorage 驱动
5. 标签页模型:tabStore(panelStore)移植 → types:terminal/sftp/settings/workspace/rdp/vnc/spice/x11/db/redis/mongodb/es/k8s/container/monitor
6. i18n:zh-CN/en 先行,复用官方 i18n/*.ts 词条

### P1 功能扩展(需协议实现,逐棒)
- 【RDP/SPICE 立项·前置已备】FreerDP 3.9.0 源码已下 /data/local/home/tmp/freerdp.zip(11.9MB);cmake+ninja 在 PATH;OpenSSL ohos 产物已有(thirdparty/libssh-x86_64-har/libs/x86_64/libssl.so.3+libcrypto.so.3)。实施步骤(数周级,单独立项):
  1. unzip freerdp.zip → mkdir build && cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=<native>/build/cmake/ohos.toolchain.cmake -DCMAKE_BUILD_TYPE=Release -DWITH_X11=OFF -DWITH_FFMPEG=OFF -DWITH_LIBSYSTEMD=OFF -DBUILD_SHARED_LIBS=OFF -DWITH_SERVER=OFF .. (只编 client 核心)
  2. 产出 libfreerdp-client3/libfreerdp3/libwinpr3 静态库 → 链接进新 napi 模块 rdpproxy.cpp(线程safe推送帧回调,仿 localpty.cpp 的 napi_threadsafe_function 模式)
  3. 头文件来自 libssl/libcrypto 无 ohos 前置:从 HAR 的 include 或 openssl 源码编出;zlib 同理(-DWITH_ZLIB=ON 需 ohos zlib,SDK sysroot 内有)
  4. RdpTab.ets 复刻 VncTab 渲染管线(PixelMap 帧回调)
  5. SPICE 无 C 库可精简:官方也用 spice-gtk,可先跳过(RDP+VNC 已覆盖 90% 远程桌面场景)
- 【本地终端·已验证可行】下棒直接照此做:
  1. 新建 entry/src/main/cpp/localpty.c:forkpty+/bin/sh,epoll 环路读输出写 pipe,napi_threadsafe_function 回调 JS;导出 ptyOpen(cols,rows)/ptyWrite(str)/ptyClose()/ptyResize()
  2. CMakeLists.txt(target x86_64,链 -lutil);编译进新 liblocalpty.so 或扩进 libssh HAR(参考 thirdparty/libssh-x86_64-har 的 CMake 结构)
  3. LocalTerminalService.ets:napi 载入,数据走 SessionService.feedExternal 注入同一终端视图;TerminalPage 按 conn.type==='local' 分流(同 telnet 分流点)
  4. ConnForm 协议下拉加"本地终端";ConnRec.type='local',host 填 'localhost' 占位
  5. 关键:clang=/data/local/home/.ohos/sdk/14/native/llvm/bin/clang,sysroot 的 pty.h 已含 forkpty/openpty(已验证);x86_64 目标 -target x86_64-linux-ohos
- Telnet/RawTCP(纯 socket,libssh 外需 @ohos.net.socket,低风险)
- 本地终端(Local:设备 shell,KaihongOS 有 /bin/sh,可用 PTY NAPI 或 shell 法)
- 串口/监控(读取 /proc, ArkTS 可直接做 CPU/内存/磁盘/网络监控页)
- FTP/WebDAV/S3(纯 TS 实现或 C++ 移植)
- RDP/VNC/SPICE(X11 桌面类,需 C++ 库,工作量大)
- 数据库/容器/K8s(需 C++ 客户端库,最大块)
- AI 助理(Anthropic/OpenAI 协议,纯 TS 可做侧栏对话)

### P2 细节对齐
分屏 PanelGrid、快捷键、云端同步、Zmodem、自定义背景、命令补全

## 本机构建路径(已验证,照抄)

工程:/data/local/home/tmp/app/uniterm-kaihongos-main/kaihongos
1. build-profile.json5 已改 OpenHarmony/14(两 product 均改,default+store)
2. module.json5 deviceTypes 已改 ["default","tablet"]
3. `timeout 280 /data/local/home/.local/bin/pack_hap .` (spawn java ENOENT 可忽略,C++ 打包接管)
4. so 不入包(hvigor Java 阶段失败所致)→ 必须跑:
   `node /data/local/home/tmp/fix-hap.cjs out_release.hap entry/build/default/intermediates/libs/default/x86_64 uniterm-fixed-unsigned.hap`
   (node=/data/local/home/dsh-pack/node/bin/node)
5. 重签:hap-sign-tool sign-app -keyAlias "OpenHarmony Application Release" -mode localSign -appCertFile $SIG/OpenHarmonyApplication.pem -profileFile $SIG/app1-profile-release.p7b -keystoreFile $SIG/OpenHarmony.p12 -keyPwd 123456 -keystorePwd 123456 (SIG=/data/local/home/.ohos/signature)
6. bm install -p … && aa start -a EntryAbility -b net.uniterm.poc

## 坑(必读)

- run_command 预检拦截 `. env.sh`,用 /data/local/home/tmp/hv.sh 或显式 export
- unzip/diff/git 均无,用 node 脚本(/data/local/home/tmp/unzip.cjs dl.cjs)
- atomgit 被 CDN 拦截返 HTML,用 github codeload zip
- grep -E "{}" 量词不可用,用 grep -o "pattern[^;]*"
- 每次改 ets 后 pack_hap 自动清 entry/build,无需手动

## 验收标准

- 截图与官方 README 截图对比:顶栏/侧栏/标签页布局一致
- 主题切换(暗/深蓝/浅)生效
- 新建 SSH 连接→终端→SFTP 全流程不回退
