# 任务书 020:M3 棒3a-收尾续棒(执行 fin2-main.cjs + REPORT)

上一收尾棒(019)于 04:18 撞 429 配额死,死前已把终版组合脚本写好。断点:`D:/uniterm/evidence/M3/RESUME-STATE-RELAY3A.md`(先读)。

## 已完成勿重做(编排者已复核)
- GBK decode E2E、GBK encode 单元 5/5、keepalive 15 跳、收藏持久、connectNow 修复(见断点文件表)
- 落盘核验:fin/fin-connections.json(A-gbk enc=gbk fav=True、C-bs bs=bs、D-vt220 bs=vt220)
- 装机:build6/sign6 HAP 已在设备(03:57)
- 终版组合脚本:`D:/uniterm/evidence/M3/r3a/fin/fin2-main.cjs`(上棒 04:18 写完未执行)

## 本棒待办
1. 读并审查 `fin/fin2-main.cjs`(它计划:od 字节级 bs/del 判别——bs 模式远端 `read -r L; od -tx1` 应显示 `5a 08`,del 模式 0x7F=VERASE 吃掉 Z 应显示空;GBK 输入框 E2E——uitest inputText 中文→hilog write bytes=2N+1 判据;卸载重装+规范导入 5 主机;终版截图)。**审出缺陷修脚本,不许改产品代码**(发现产品 bug 除外,修了须重建重装重验)。
2. 执行它,收集:hilog 判据行、三张终版截图(截图前 dump 断言前台是 net.uniterm.poc 且含期望标记文本)、卸载重装后的列表终态。
3. 若 inputText 中文仍被工具链损坏成 `?`(bytes=9 而非 17 之类),如实记录为工具链限制——native 单元 5/5 + 判据结论照写,不算失败。
4. 写 `D:/uniterm/evidence/M3/r3a/REPORT-relay3a.md`:合并上棒表(断点文件)+ 本棒证据,含工具链限制说明(欲知详情看断点文件)。
5. 汇报:各项 ✅/❌ + 关键 hilog 行 + 证据路径清单。

## 红线
- 欲知任何上游行为以 `D:/uniterm/upstream` 源码为准(引用行号)。
- 上下文将尽或 429:更新 RESUME-STATE-RELAY3A.md 再退。
