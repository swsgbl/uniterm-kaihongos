角色与使命:继续 uniterm KaihongOS 桌面版 M1a,你是第 4 棒(预计最后一棒)。第 3 棒已产出并核实:entry-default-signed.hap(8,980,101B,verify-app 全绿)、scripts\{build,sign,deploy}.cmd 就绪,bundleName=net.uniterm.poc(编排者已批准该偏差)。断点事实源:D:\uniterm\evidence\M1a\RESUME-STATE.md。

环境事实:设备 hdc -t 127.0.0.1:5555 在线(KaihongOS 5.0.2.57,x86_64,API24);SSH 靶机 10.0.2.2:22(guest 经 SLIRP 到宿主 OpenSSH);失败路径端口 10.0.2.2:2222(预期连不上)。

本棒任务(按序):
1. 真跑 scripts\deploy.cmd:install → aa start。若安装被拒(签名/权限),如实记录错误并修复后重试(修复仅限:签名材料重签、module.json5 加 ohos.permission.INTERNET 等 system_grant 权限后重建;不得改验收标准)。
2. 冷启动健康检查:hilog 抓启动窗口段,确认无 FATAL/无 crash 重启循环(bm dump 或 hidumper 确认进程存活)。
3. PoC 双路径验证(需要 UI 交互的步骤用你 harness 的设备自动化能力:uitest/hdc shell uinput/截图判定循环,此前会话已有成熟打法):
   a. 点击「SSH PoC 连接 10.0.2.2:22」→ 等待结果区出现 SSH-2.0-... banner → 截图 + 导出 hilog(uniterm.poc tag,须有成功+banner 原文);
   b. 点击「失败路径测试 10.0.2.2:2222」→ 结果区显示错误、应用不 crash → 截图 + hilog;
   c. 若 banner 取不到:先查 hilog 定位(native so 加载失败?socket 权限?libssh 报错串?),把真实原因写进报告,禁止编造成功。
4. 证据归档 D:\uniterm\evidence\M1a\:截图≥3(首页/成功/失败,文件名含序号)、hilog 导出(成功+失败+启动段)、install 日志、REPORT.md(按任务书 003 的 REPORT 要求写:做了什么/结果/遗留)。
5. 勘误:docs\ADAPTATION_DESIGN.md 里 2026-10-24 → 2026-09-20(全部出现处)。
6. 更新 RESUME-STATE.md 标注 M1a 完成态。

红线(不变):banner 必须真实网络读取;不得 hardcode;不 crash 判定以 hilog 为准;所有文件只落 kaihongos 与 evidence 目录。

回复要求:≤20 行:装机/启动/PoC成功/PoC失败 四项各一行(✅/❌+一句话),banner 实测原文一行,截图与日志相对路径,遗留问题。
