角色与使命:uniterm KaihongOS 桌面版进入 **M1b 连接管理器**,你是本里程碑第 1 棒。M1a 已由编排者终验通过(装机/启动/PoC 双路径全绿,banner 实测 SSH-2.0-OpenSSH_10.2p1 Ubuntu-2ubuntu3.6)。工程与工具链全就绪:D:\uniterm\kaihongos(bundleName=net.uniterm.poc,scripts\{build,sign,deploy}.cmd 可用,本地 x86_64 libssh HAR 已接)。

断点纪律(继承):每棒结束更新 D:\uniterm\evidence\M1b\RESUME-STATE.md(新建);上下文将尽先固化断点;一次一件事;不改 D:\uniterm\upstream 与 thirdparty\ohos_ssh-src;产物只落 kaihongos 与 evidence\M1b。

本棒任务:连接管理器核心(数据层 + CRUD + 分组 UI)。

数据模型(以上游为准,字段名必须逐字兼容,参考 upstream\backend\store\connection_store.go 与 frontend\src\types):
- 存储文件:应用沙箱 files/connections.json,顶层 {"groups":[...],"connections":[...]};
- Group:{id,name,parentId}(parentId 根级为 null;id 用 "g-" 前缀+短随机);
- Connection(本里程碑 SSH 子集,其余字段写入时用上游默认值):id("c-"前缀)、name、remark、type:"ssh"、host、port(默认22)、user、authType("password"|"key"|"keyText")、password、keyPath、keyContent、groupId(根为 null)、encoding:"utf-8"、backspaceKey:"del"、initialCols、initialRows、postLoginScript、logOnConnect、tunnelSSHConnId:""、proxyId:"";
- 读写必须整体 JSON 序列化,保持与上游文件可互换(字段名/嵌套/类型一致,未知字段读入时保留)。

UI(ArkUI,zh-CN,桌面形态,可用侧栏+列表,风格整洁即可):
1. 连接列表页:按分组分区显示主机(名称/host:user:port/类型图标或文字),支持新增/编辑/删除主机(表单含上述 SSH 子集字段,校验:host 非空、port 1-65535、authType 三选一且相应凭据字段必填);
2. 分组:新增/重命名/删除分组(删除时组内主机移到根级,不许丢);主机可在表单里选所属分组;
3. 数据即时落盘(保存即写 connections.json),应用重启后列表完整恢复;
4. M1a 的 PoC 页保留为二级页或入口按钮,别删(回归用)。

本棒验收线(必须实跑):
- build.cmd + sign.cmd + deploy.cmd 全链路装机;
- 自动化操作:新建分组"生产环境"→新建 2 台主机归入该组→重启应用(force-stop+start)→列表仍显示 1 组 2 主机;
- 编辑其中 1 台改端口→保存重启→端口保持;删除 1 台→重启→剩 1 台;
- 截图≥3(列表/表单/编辑后)+ hilog(tag=uniterm.store 记录读写计数)归档 evidence\M1b\;
- hdc file cat 或recv 导出设备上的 connections.json 落证据,人眼可见结构正确。

红线:数据模型字段名与上游逐字一致(这是 M1b 棒2 导入兼容的前提);不引入 ohpm 新三方库(自绘 UI);不得为省事把 connections.json 放沙箱外。

回复要求:≤20 行:UI 完成度一行、四步验收各一行(✅/❌+一句话)、导出的 connections.json 关键片段、新踩坑、遗留。
