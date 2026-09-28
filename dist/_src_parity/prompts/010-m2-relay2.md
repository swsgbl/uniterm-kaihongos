角色与使命:uniterm KaihongOS M2 第 2 棒,**只做 native/napi 会话层,不碰 ArkTS UI**。断点事实源 D:\uniterm\evidence\M2\RESUME-STATE.md(relay-1 已定接口设计与红线,直接照做)。纪律继承:上下文将尽先固化;一次一件事;输出只看关键行。

背景:WSL 靶机已就绪(evidence\M2\target.txt:uterm/dev123@10.0.2.2:22);napi 骨架在 D:\uniterm\kaihongos\thirdparty\libssh-x86_64-har\src\main\cpp\napi\;既有 ssh2_client.Start() 含 publickey→password 回退可复用;CreateShell() 现为固定 80x24 + ReadUntilPrompt,需改参数化+非阻塞读循环。

本棒任务:
1. 改造 HAR napi 层,新增会话接口(设计已在 RESUME-STATE.md):
   - SessionOpenWithPassword(host,port,user,password,cols,rows) → sessionId:连接(必须显式 set SSH_OPTIONS_USER + SSH_OPTIONS_SSH_DIR,沙箱无 passwd)+密码认证+request_pty(初始 cols×rows)+request_shell;失败返回带 libssh 错误串的 reject;
   - 读循环:独立线程非阻塞 poll,chunk 经 napi threadsafe function 推 ArkTS,事件流 on('data', {id, chunk})、on('closed',{id,reason})、on('error',{id,message});UTF-8 边界处理(多字节跨 chunk 残留缓冲);
   - WriteStdin(id, text) / ResizePty(id, cols, rows) / CloseSession(id);
   - Index.d.ts 与 libssh.ets 包装同步;hilog tag=uniterm.napi(open/write/resize/close/data 计数)。
2. 用既有配方 thirdparty\build-napi-x86_64.sh 重编 libssh_ohos_napi.so,五件套归位 HAR,重装到 entry(ohpm install)。
3. 回归冒烟:build.cmd+sign.cmd+deploy.cmd 装机,应用冷启动无 FATAL(既有 PoC 按钮仍可用——证明 napi 改动没破坏旧接口)。

本棒验收线:napi 接口编译通过 + so 落位 + 冷启动回归通过。不需要在 UI 里调会话接口(那是棒3)。
归档:编译日志关键行、冷启动 hilog、RESUME-STATE.md 更新。

红线:不硬编码任何会话数据;错误信息必须来自 libssh 真实返回;不改 upstream 与 ohos_ssh-src;产物只落 kaihongos 与 evidence\M2。

回复要求:≤12 行:接口清单一行、编译✅/❌、装机回归✅/❌、踩坑、给棒3的注意事项。
