# 任务书 019:M3 棒3a-收尾(ConnForm 两字段核验 + 有效截图 + REPORT)

你上一棒(会话 tegnzf,544 轮)已完成了 GBK/保活/收藏的全部硬核工作,在核验 ConnForm 下拉时会话寿终。断点已由编排者固化在 `D:/uniterm/evidence/M3/RESUME-STATE-RELAY3A.md`,**先读它**,不要重做已完成的项(GBK 表、keepalive、收藏、connectNow 修复都已验证,代码都在)。

## 背景
- 工程 `D:/uniterm/kaihongos`(bundleName=net.uniterm.poc),构建签名安装照旧:`scripts\build.cmd` → `scripts\sign.cmd` → `scripts\deploy.cmd`。设备 127.0.0.1:5555,靶机 uterm@10.0.2.2:2222(target-relay 已在跑,勿动 22/2222 端口)。
- 上棒装的 HAP(build5,02:27)已含全部功能代码,**先验证设备上这个包还在、版本对**(build 时间戳 ≥ 02:27),不对再重装。

## 待办(全部做完)
1. **ConnForm 两字段核验**:启动 app → 打开 A-gbk 主机编辑页 →
   a. 核 encoding 下拉当前显示 `gbk`(若折叠,点开展开态截图或 dump 证明选项集含 utf-8/gbk);
   b. 把 backspaceKey 从 del 切到 **bs**,点保存;
   c. 拉设备 `connections.json`(`hdc file recv` 沙箱路径或应用内导出)证明 `encoding:"gbk"` 与 `backspaceKey:"bs"` 已落盘。
2. **bs 行为实证**:用 bs 模式连接靶机,在终端按一次退格,hilog 抓 `write id=.. bytes=1`,配合远端侧证据(如 `stty -a` 显示 `erase = ^H`,或脚本读 stdin 十六进制)证明发送的是 **0x08**(对照:del 模式发 0x7F,可再切回 del 各按一次作对照)。若 E2E 注入退格键不可行,用 want 通道 postLoginScript 发送单个 `\x08`/`\x7f` 字节亦可(纯 ASCII,不走中文,无编码损坏问题)。
3. **有效截图 3~4 张**:列表页(含★收藏标与快捷条)、ConnForm 编辑页(encoding+backspaceKey 下拉可见)、终端页(GBK 主机,屏幕含「中文测试」)。**截图前必须确认前台是 net.uniterm.poc**(hilog 或 dump bundleName);上棒 fav.jpeg/now.jpeg 拍成了别的应用(AIOS 设置页/系统 picker),不要重蹈——若截图工具只能拍到错误窗口,改用 `hdc shell snapshot_display -f` 或说明通道限制、以 dumpLayout+文本提取替代并在 REPORT 中声明。
4. **写 REPORT**: `D:/uniterm/evidence/M3/r3a/REPORT-relay3a.md`,汇总本棒+上棒全部结论(从 RESUME-STATE-RELAY3A.md 的表开始,补新增证据),必须含:hilog 计数、落盘 JSON 抽查字段、截图清单、以及「hdc want 通道中文按 GBK 传输损坏=工具链限制非 app 缺陷」的说明(单元测试 5/5 已覆盖 encode 路径)。

## 红线
- 不改已验证的功能代码;发现 bug 才许修,修了必须重建重装重验。
- 所有屏幕断言给 hilog/dump 佐证,引用上游行为以 `D:/uniterm/upstream` 源码为准(引用行号)。
- 上下文将尽或配额 429:更新 RESUME-STATE-RELAY3A.md 再退。

## 汇报格式
结束后输出:各项 ✅/❌ + 关键日志行 + 证据文件相对路径清单。
