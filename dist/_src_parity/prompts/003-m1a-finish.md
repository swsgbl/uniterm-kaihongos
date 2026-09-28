角色与使命:继续 uniterm KaihongOS 桌面版 M1a 收尾。你是上一会话(hmh session 2026-09-20T07-26-37)的接任者,断点状态已固化在 D:\uniterm\evidence\M1a\RESUME-STATE.md,编排者已逐项核实其真实性(libssh.so.4/libcrypto.so.3/libssl.so.3 产物、HAR 骨架、脚本均在),你直接采信它,禁止重复探索。

执行纪律(上一会话死于上下文耗尽,必须遵守):
- 按 RESUME-STATE.md「待办」1→7 顺序执行,一次只做一项,做完即改状态。
- 不重读大文件、不重新侦察环境、不重复跑已通过的构建;需要事实先查 RESUME-STATE.md 与 thirdparty/build-x86_64.sh。
- 命令输出裁剪后再看,长日志落盘、只 grep 关键行。
- 若你预估自己上下文即将耗尽:立刻更新 RESUME-STATE.md(已完成/待办/新踩的坑),输出摘要,干净收束。宁可再接力一次,不可烂尾。

待办(照抄自 RESUME-STATE.md,以文件最新版为准):
1. [关键] HAR 骨架 napi 层加 getServerBanner:ssh2_client.cpp 的 Start() 在 ssh_connect 成功后调 ssh_get_serverbanner()(libssh 0.11 API)存成员;ssh2_napi.cpp 加 Promise<string> 方法;napi_init.cpp 注册;types 补声明。
2. WSL 用同 XFLAGS 编 libssh_ohos_napi.so(OHOS_ARCH=x86_64),产物连同 libssh.so.4/libcrypto.so.3/libssl.so.3/libc++_shared.so 放 HAR 骨架 libs/x86_64。
3. entry 依赖本地 HAR(file:../thirdparty/libssh-x86_64-har),Index.ets 按 @ohos/libssh 官方用法 import。
4. scripts\build.cmd / sign.cmd / deploy.cmd(hap-sign-tool 自签,p12 口令 123456,材料优先复用 ~/.ohos/config,.p7b 缺则生成)。
5. 首页 UI:"uniTerm KaihongOS M1a"+构建号+「SSH PoC 连接 10.0.2.2:22」按钮+结果区,banner 渲染在页面上;失败路径(10.0.2.2:2222)页面上显示错误;hilog tag=uniterm.poc。
6. 装机验证(install→冷启动无 FATAL→成功/失败双路径)+ 截图≥3 + hilog/构建/install 日志 + D:\uniterm\evidence\M1a\REPORT.md。
7. 勘误 docs/ADAPTATION_DESIGN.md 日期 2026-10-24→2026-09-20。

红线(继续有效):
- banner 必须来自真实网络读取,禁止 hardcode;
- 不改 D:\uniterm\upstream 与 thirdparty/ohos_ssh-src(只读);
- 所有产物只落 D:\uniterm\kaihongos 与 D:\uniterm\evidence\M1a;
- 出现方案级障碍(如 napi so 装载失败、签名被设备拒)先如实上报,不得静默降级验收标准。

回复要求:结束时 ≤25 行摘要:七项待办各一行状态(✅/❌+一句话),PoC 实测 banner 字符串原文,证据文件相对路径,遗留问题。
