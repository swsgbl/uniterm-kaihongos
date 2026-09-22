角色与使命:uniterm KaihongOS 进入 **M3 生产强化**,第 1 棒:**keyText 认证 + 凭据加密存储**。M2 已整体终验通过(ANSI/光标/键盘直通/滚动/性能 2.2MB/s)。断点事实源 D:\uniterm\evidence\M2\RESUME-STATE.md(M3 遗留清单+10 条新坑)。纪律继承:每棒更新 D:\uniterm\evidence\M3\RESUME-STATE.md;上下文将尽先固化;不改 upstream;产物只落 kaihongos 与 evidence\M3。

背景:M2 期间 napi 会话接口只做了密码认证;凭据目前明文存 connections.json(上游无 PasswordStore 时拒存明文 fail-closed,我们目前是明文——本棒补齐)。

任务 A:keyText 认证(native+UI)
1. napi 层:session 增加公钥认证路径——SessionOpen 支持传 privateKey 内容(PEM 文本,libssh ssh_pki_import_privkey 内存导入,不落盘)或 keyPath(沙箱内路径);优先 publickey,失败按上游语义回落 password(上游 Start() 有此回退逻辑可参考)。错误信息保持 libssh 原文。
2. UI:主机表单 authType=keyText 时提供 PEM 多行输入(或从文件读);测试连接按钮走同一路径。
3. 验收:WSL 生成测试密钥对(ssh-keygen -t ed25519,无口令与有口令两种),公钥写入 uterm 账号 authorized_keys;新建 keyText 主机 → 终端连出提示符 + hilog 认证方式日志(publickey);有口令密钥需支持 passphrase 输入(表单字段)。

任务 B:凭据加密存储(上游 enc:v1 兼容)
1. 参照 upstream backend/store 加密实现(crypto.go/importer 里 enc:v1 前缀、PBKDF2-SHA256 210k 迭代、AES;精确算法以上游代码为准逐字复刻):
   - 应用内设置"主密码"(首次设置,存 HUKS 或派生密钥缓存;忘记主密码=凭据不可恢复,与上游语义一致);
   - connections.json 中 password/keyContent/passphrase 字段统一 enc:v1: 加密落盘;读取时解密;
   - **兼容性硬指标**:用上游 Go 代码实际加密出的 enc:v1 字符串,我们的 ArkTS 能解密;我们加密的上游能解(在 WSL 里构建/运行上游 crypto 相关测试或最小 Go 程序完成互导验证,证据落盘)。
2. 导入器联动:导入含 enc:v1 的 connections.json/.utm 时,提示输入主密码解密(有 PasswordStore 语义);无主密码则该字段置空并标注。
3. 验收:设置主密码→保存含密码/keyText 主机→导出 connections.json 落盘证据,密码字段为 enc:v1: 前缀非明文;重启应用+正确主密码→可连;错误主密码→凭据字段标注不可用;Go/ArkTS 互导样本各≥1 组证据。

验收与归档(evidence\M3\):截图≥4(keyText 表单/公钥登录成功/加密落盘 JSON/主密码错误提示)、hilog、Go 互导样本与命令记录、REPORT-relay1.md、RESUME-STATE.md。

红线:加密算法参数必须与上游 bit 级一致(210k 迭代 SHA256 等,以上游源码为准);私钥导入不落盘;禁止为省事降级成"伪加密"(XOR/base64 之类)。

回复要求:≤16 行:A/B 完成度各一行、验收项各一行(✅/❌+关键观测)、互导证据路径、踩坑、遗留。
