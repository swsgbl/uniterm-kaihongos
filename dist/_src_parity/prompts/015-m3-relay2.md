角色与使命:uniterm KaihongOS M3 第 2 棒:**.utm 导入导出(含加密)+ 身份库**。棒 1(keyText+enc:v1)已终验通过。断点事实源 D:\uniterm\evidence\M3\RESUME-STATE.md(含 want 通道 credSetup/credUnlock 用法、uitest 键盘坑、双 load 修复)。纪律继承;产物只落 kaihongos 与 evidence\M3。

任务 A:.utm 完整双向(上游 importer/uniterm.go + 上游导出逻辑逐字对照)
1. 导出:应用内「导出」→ .utm 文件(format:"uniterm",version:1,groups+connections 内嵌);主密码已设 → 支持**加密 .utm**(kdf 块:PBKDF2-SHA256,**迭代数以上游 uniterm.go 导出代码为准**——设计书曾记 210k,以源码实测为准并记录;salt/算法逐字对齐);未设主密码 → 明文导出(密码字段 enc:v1 或空,同上游语义)。导出文件落到应用沙箱 + hdc recv 拉回宿主归档。
2. 导入:已有明文导入器升级——支持加密 .utm(输入主密码解密;kdf 参数按文件头自适应);id 重新生成;错误文件/错误密码给明确提示。
3. **真·Go 互导(必做,棒1 的遗留)**:在 WSL 里用上游源码跑最小 Go 程序(或直接 `go test` 上游 importer 相关用例):
   - 上游 Go 导出的 .utm(明文+加密各一) → 我们导入 → 字段一致;
   - 我们导出的 .utm(明文+加密各一) → 上游 Go importer 解析/解密 → 字段一致;
   - 同样跑 connections.json 双向(enc:v1 字段)。
   每组样本文件+命令+输出落 evidence\M3\interop-go\。go 环境没有就 apt/golang.org.cn 装(WSL sudo -n 免密)。

任务 B:身份库(identities)
1. 数据层:identities.json({identities:[{id,name,username,authType,password?,keyPath?,keyContent?}]}),凭据字段走棒1 的 seal/reveal(主密码语义一致);连接的 authType=identity 引用 identityId。
2. UI:身份管理页(增删改查);主机表单 authType=identity 时下拉选身份。
3. 验收:建身份(密码型+keyText 型各一)→ 两台主机引用身份 → 均连接成功(hilog authMethod);重启+credUnlock 后仍可连;identity 删除时引用它的主机标注"身份缺失"并可改绑。

验收与归档(evidence\M3\):截图≥5(导出文件、加密 .utm 导入、身份管理页、identity 主机连接、错误密码提示)、interop-go\ 样本与输出、hilog、REPORT-relay2.md、RESUME-STATE.md 更新。

红线:kdf/加密参数一律以上游源码为准并引用行号;互导必须真 Go,不许再用 Node 代理充当"Go 互导"(棒1 的 Node 证据保留但标注为算法等价验证);导出导入真实读写文件,禁止内存糊弄。

回复要求:≤18 行:A/B 各一行完成度、Go 互导四组结果各一行(✅/❌)、kdf 实测迭代数一行、验收要点、踩坑、遗留。
