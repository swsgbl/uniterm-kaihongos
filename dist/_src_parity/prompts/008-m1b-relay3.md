角色与使命:uniterm KaihongOS M1b 第 3 棒(收官棒)。前两棒已完成:连接管理器 CRUD/分组/持久化(四步验收全绿)。断点事实源 D:\uniterm\evidence\M1b\RESUME-STATE.md。本棒补齐 M1b 剩余两块:**导入兼容**与**测试连接**,跑完 M1b 终验。

任务 A:导入(上游格式兼容)
1. 参照 upstream\backend\importer\uniterm.go 的解析逻辑(.utm:{format:"uniterm",version:1,encrypted,groups,connections})与 connections.json 顶层结构,实现 ArkTS 导入器:
   - 仅支持明文(encrypted:false / 无 enc:v1 前缀);遇到加密文件给出明确错误提示"加密文件 M3 支持";
   - 导入时为每条 connection/group **重新生成 id**(上游 ImportResult 行为:parseUniterm 用 fresh ids),冲突不覆盖既有数据,合入现有列表;无法识别的 type(如 telnet/database)也导入保存(占位),但标注"暂不支持连接";
   - 未知字段保留不丢。
2. 入口 UI:连接列表页"导入"按钮 → 系统文件选择器(DocumentViewPicker);自动化验收若驱动 picker 困难,允许备用入口:识别 /data/local/tmp/import-test.utm|json 的"开发者导入"按钮(两个入口都要有,验收走哪个都行,截图注明)。
3. 验收样例你自己构造(严格按上游 schema):
   - sample-A connections.json:2 组 3 主机(含 1 台 type:"telnet" 占位);
   - sample-B .utm 明文:1 组 2 主机(1 台 authType:"keyText" 带 PEM);
   - 两份样例文件本体也归档 evidence\M1b\import-samples\。

任务 B:测试连接按钮
- 主机列表项或详情提供「测试连接」:调本地 libssh HAR 连 host:port 取 banner,成功显示"✓ SSH-2.0-…"及耗时,失败显示错误(复用 M1a PoC 通路);
- 验收:对 10.0.2.2:22 测通;对一个不通端口显示错误不 crash。

M1b 终验(全部实跑并归档 evidence\M1b\):
1. 导入 sample-A → 列表 +2 组 +3 主机(telnet 带占位标注),hilog uniterm.import 计数;
2. 导入 sample-B → +1 组 +2 主机,keyText 主机编辑表单可见 PEM 内容;
3. 重启应用 → 导入数据全部保持;
4. 测试连接成功/失败双路径截图;
5. 截图≥4(导入前后、keyText 表单、测试连接)、hilog、REPORT-final.md(M1b 三棒总汇:CRUD✅+导入✅+测试连接✅+遗留)、RESUME-STATE.md 标注 M1b 完成。

纪律:继承(一次一件事/上下文将尽先固化/不改 upstream/产物只落 kaihongos 与 evidence\M1b)。导入解析必须真实读文件解析,禁止把样例内容硬编码进 UI。

回复要求:≤18 行:A/B 完成度各一行、终验 5 项各一行、修复 bug、遗留、证据相对路径。
