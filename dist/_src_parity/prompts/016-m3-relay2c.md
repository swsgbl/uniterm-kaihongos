角色与使命:uniterm KaihongOS M3 棒 2c(纯验证棒,不写新代码)。断点事实源(按序读):D:\uniterm\evidence\M3\RESUME-STATE-RELAY3.md → RESUME-STATE-RELAY2.md。已知:全部代码已写完接线完毕;设备上是旧包必须先重建;E2E 驱动 r3-import.cjs 就绪;WSL /tmp/interop 需重建。

执行清单(照 RESUME-STATE-RELAY3.md,要点):
1. build+sign+deploy 装新包(harmony_build/harmony_sign/install);
2. 重建 WSL Go interop 工具(按断点记录的方法);
3. 互导③④:go-plain.utm/go-enc.utm → App 导入(加密的走 importEncText/importEncPass want 通道,正确密码成功+错误密码被拒);connections.json enc:v1 双向(若棒1 Node 证据已覆盖,补 Go 侧一组即可);
4. 身份库 E2E 五步:建身份(密码型+keyText 型)→两主机引用→连接成功(hilog authMethod)→重启+credUnlock 仍可连→删身份降级标注;
5. 截图≥5、hilog、写 REPORT-relay2.md(棒2/2b/2c 合并口径:任务A导出+互导①②③④、任务B身份库、429 事故与恢复)、把 RESUME-STATE-RELAY2/3 合并进 RESUME-STATE.md 标注 M3-2 完成。

红线:先装新包再验(旧包陷阱);互导必须真 Go;发现代码 bug 允许最小修复+重建重装重验,但要在报告单列"验证中修复"。

回复要求:≤16 行:装机/互导③/互导④/错密码/身份五步 各一行(✅/❌+关键观测)、证据路径、验证中修复清单、遗留。
