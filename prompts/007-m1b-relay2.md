角色与使命:uniterm KaihongOS M1b 第 2 棒。第 1 棒已交付连接管理器全部代码并装机(UI 渲染经 dumpLayout 确认),但四步 CRUD 自动化验收未跑完。断点事实源:D:\uniterm\evidence\M1b\RESUME-STATE.md(含已标定的控件坐标与命令,直接用)。

本棒任务 = 补跑验收 + 归档,**原则上不写新功能**;验收中暴露的 bug 允许修复(修复后重建重装重跑该步)。

四步验收(用 harness 设备自动化,按 RESUME-STATE 坐标先 dumpLayout 校准再点击):
1. 建分组"生产环境" → 建 2 台主机(web1: 10.0.2.2:22 user=root password=dev123;web2: 10.0.2.2:2222 user=test password=t456)归入该组 → 截图(表单+列表);
2. force-stop 重启应用 → 列表仍 1 组 2 主机 → 截图 + hilog(uniterm.store)证据;
3. 编辑 web2 改端口 2222(已是 2222 则改 8022)→ 保存重启 → 端口保持 → 截图;
4. 删除 web2 → 重启 → 剩 1 台 web1 → 截图。
验收期内任何一步失败:保留现场(截图+hilog),修复,重跑该步,失败历史也要留痕。

归档(evidence\M1b\):
- 截图补齐(表单/列表/编辑/删除后,至少 4 张新图);
- hilog 导出含 uniterm.store 读写计数;
- 从设备导出最终 connections.json(hdc file recv 或 shell cat 重定向),文件落 evidence\M1b\connections-export.json;
- 更新 RESUME-STATE.md;
- 写 evidence\M1b\REPORT-relay2.md:四步各一段(操作/观测/结论)+ 发现并修复的 bug 清单。

红线:数据必须真实落盘恢复(重启核验),不得用内存状态糊弄;连接数据里的密码就写 dev123/t456(内部测试凭据);文件只落 kaihongos 与 evidence\M1b。

回复要求:≤15 行:四步各一行(✅/❌+关键观测)、导出 json 的 connections[0] 关键字段、修复的 bug 一行一个、遗留。
