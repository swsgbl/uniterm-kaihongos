角色与使命:uniterm KaihongOS M2 第 3 棒:**ArkTS 会话服务 + 终端页 + 五项验收**。棒2 已交付 native 会话层(接口契约见 D:\uniterm\evidence\M2\RESUME-STATE.md:全局单例事件回调需统一 dispatcher 按 ev.id 分发;sessionOpenWithPassword/ writeStdin/resizePty/closeSession;认证失败 reject 的 Error.message 即 libssh 原文)。断点纪律继承。

本棒任务:
1. SessionService.ets:Connect(conn, cols, rows)(authType=password 走会话接口;keyText 本棒可留 TODO 但代码结构预留)、Write/Resize/Close;事件 dispatcher 按 id 分发到对应会话回调;hilog tag=uniterm.session(connect ok/fail、write/resize/close、data 计数与字节数)。
2. TerminalPage.ets(**必须注册 main_pages.json**,棒1断点提醒过):
   - 顶部:主机名 + 状态徽标(connecting/connected/disconnected/error + 原因)+ 关闭按钮;
   - 主体:等宽字体滚动输出流(接收 data 事件追加渲染;ANSI 转义序列先剥除,颜色留棒4);自动滚到底;
   - 底部:单行输入框 + 发送按钮(Enter 发送并补 \n);
   - 进入页面时按字体宽度量测可用列行 → Connect 传初始 cols/rows;页面尺寸变化时 Resize(节流 300ms);
   - closed/error 事件 → 状态更新 + 原因显示,不 crash。
3. ConnList 行操作加「连接」入口(现有 测试/编辑/删除 旁),点击跳 TerminalPage 传 connId。

五项验收(全部实跑,自动化驱动,证据归档 evidence\M2\):
1. 连 web1(或新建主机 uterm@10.0.2.2:22 密码 dev123)→ 终端页出现远端提示符 uterm@ubuntu:~$;
2. 输入 echo UT_OK_123 → 输出流出现 UT_OK_123(**必须是远端回显**,hilog data 计数为证);
3. 输入 stty size → 输出 "NN MM" 且与页面量测一致(±1);
4. exit → closed 事件 → 状态 disconnected(截图+hilog);
5. 错密码主机 → error 状态显示 libssh 原始错误 → 改回正确密码重连成功。
截图≥5、hilog 导出、REPORT-relay3.md、RESUME-STATE.md 更新。

红线:输出仅来自真实 ssh 数据流;禁止 UI 假回显;认证错误文案来自 libssh;产物只落 kaihongos 与 evidence\M2;不改 upstream/ohos_ssh-src。

回复要求:≤16 行:五项各一行(✅/❌+关键观测)、SessionService/终端页完成度一行、修复的 bug、遗留(给棒4:ANSI 颜色/光标/键盘直通/性能基准)。
