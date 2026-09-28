# 任务书 023:M3 棒3b-收尾(截图 + REPORT + 终态)

实现棒(022)于 10:51 撞 429 死,**五项 E2E 判据已全部通过且编排者已独立复核**(勿重跑):
1. 列目录:hilog `sftp list dir=. n=10`、`dir=.ssh n=3`(n=10 与 WSL 真实 `ls -a|wc -l` 一致)
2. 导航:path `.`→`.ssh`→`.` 切换正常
3. 下载:`sftp dl bytes=3771 ms=3 fail=0`,宿主 dl-bashrc MD5=1f98b8f3f3c8f8927eca945d59dcc1c6 == WSL /home/uterm/.bashrc
4. 上传:`sftp ul bytes=3771 ms=53 fail=0` + 远端 mtime 10:40:36.786 与 hilog 同刻(落盘实证)
5. 断连:`list FAIL Socket error: disconnected`,面板存活(app pid 不变),无 FATAL
证据在 evidence/M3/r3b/(hilog-final.txt、dl-bashrc、*.json)。

## 本棒待办(小范围)
1. **补 3 张有效截图**(截图前 dump 断言前台 net.uniterm.poc,3a 教训):①SFTP 面板列目录(10 items 可见);②.ssh 子目录视图或返回后视图;③断连错误态(`error: Socket error: disconnected` 可见)。若终端/SFTP 面板已不在该状态,按 e2e*.cjs 脚本重走到对应状态再拍(设备 HAP 就是实现棒装的那版,native 已含 sftp)。
2. **可选加固**(若快):上传一个**内容独特**的小文件(如 `r3b-marker-<ts>` 文本)到远端,sudo cat 验证内容——把上传从"同内容回写"升级为"独立内容落盘"。
3. **写 `evidence/M3/r3b/REPORT-relay3b.md`**:五判据表(编排者复核结论如上,引用 hilog 行/md5/mtime)+截图清单+实现摘要(native 5 函数/chanMutex 串行化/SftpPanel.ets/入口)+遗留项。
4. 更新 `evidence/M3/RESUME-STATE-RELAY3B.md` 为完结态(或声明由 REPORT 取代)。
5. 汇报:各项 ✅/❌ + 证据路径清单。

## 红线
- 不改产品代码;发现缺陷如实记录并标 M3-4,不阻塞收官。
- 429/上下文将尽:更新断点再退。设备/靶机环境同 022(hdc 5555、uterm@10.0.2.2:2222、主密码 mp-735、勿动 22/2222 端口)。
