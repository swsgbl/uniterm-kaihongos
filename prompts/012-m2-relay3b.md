角色与使命:uniterm KaihongOS M2 第 3b 棒(重跑验收)。上一会话已完成 SessionService/TerminalPage/连接入口的编码与装机,验收中断于**靶机链路故障**(宿主 22 端口转发器消失)。**编排者已重建并固话靶机链路,不要动它,直接用**:

靶机链路(编排者管理,只读使用):
- 链路:guest 10.0.2.2:2222 --SLIRP--> 宿主 127.0.0.1:2222 (node relay) --> WSL Ubuntu sshd:22
- 账号:uterm / dev123
- relay 脚本:D:\uniterm\kaihongos\scripts\target-relay.js(已在后台运行,日志 evidence\M2\relay.log)
- 健康检查两步:1) `netstat -an | findstr ":2222"` 有 LISTENING;2) host 上 node 连 127.0.0.1:2222 应立即收到 SSH-2.0 banner。若 relay 挂了(罕见):`powershell -NoProfile -Command "Start-Process node -ArgumentList 'D:\uniterm\kaihongos\scripts\target-relay.js' -WindowStyle Hidden"` 拉起后继续。禁止再在 22 端口做任何实验。

本棒任务:
1. 确认设备上装的是棒3 版本(含 TerminalPage);若不确定,重跑 build/sign/deploy 一次(便宜,保干净)。
2. 连接主机改为/新建:uterm@10.0.2.2:**2222** 密码 dev123(名称 uterm-wsl)。
3. 五项验收(每项截图+hilog 双证据,归档 evidence\M2\):
   ① 连接 → 终端页出现 uterm@ubuntu 提示符(如 uterm@ubuntu:~$);
   ② 输入 echo UT_OK_123 → 远端回显 UT_OK_123;
   ③ 输入 stty size → 行列与页面量测一致(±1);
   ④ exit → closed 事件 → 状态 disconnected + 原因;
   ⑤ 错密码主机(uterm-bad)→ error 状态显示 libssh 原始错误 → 修正密码重连成功。
4. 写 REPORT-relay3.md(棒3+3b 合并口径:开发内容、五项结果、靶机链路事故复盘一段)、更新 RESUME-STATE.md 标注 M2 棒3 完成。

红线:回显必须来自真实 ssh 数据流(hilog uniterm.session data 计数);认证错误文案来自 libssh 原文;若链路再断,先跑健康检查两步并留痕,不要自行改链路方案。

回复要求:≤14 行:五项各一行(✅/❌+关键观测)、链路健康检查一行、修复/踩坑、遗留(给棒4)。
