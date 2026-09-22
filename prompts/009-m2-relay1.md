角色与使命:uniterm KaihongOS 桌面版进入 **M2:SSH 终端最小可用**,你是本里程碑第 1 棒。M1a/M1b 已终验通过(工具链/libssh x86_64/连接管理器/导入兼容全部就绪)。断点纪律继承:每棒更新 D:\uniterm\evidence\M2\RESUME-STATE.md;上下文将尽先固化;不改 upstream 与 ohos_ssh-src;产物只落 kaihongos 与 evidence\M2。

本棒目标:**SSH 交互会话打通**(认证 + shell 通道 + 数据流),终端渲染先做"够用"版。

1. WSL 靶机准备(一次性):
   - 在 WSL Ubuntu 确保 sshd 运行且密码登录开启;创建测试账号 uterm/dev123(sudo -n 免密可用);sshd 监听确认(宿主 127.0.0.1:22 即它,guest 走 10.0.2.2:22);
   - 把账密写入 evidence\M2\target.txt。
2. native/napi 层扩展(改 thirdparty\libssh-x86_64-har 骨架,自家的可改):
   - 在现有客户端封装上加:密码认证(user/password)、打开 shell 通道(request_pty + request_shell)、write(键盘输入)、异步读循环(输出回调到 ArkTS,napi threadsafe function)、resize(ssh_channel_change_pty_size)、close;
   - 事件流:connected/data(chunk,UTF-8 文本)/closed(reason)/error(string);
   - 用既有 WSL 编译配方(thirdparty/build-napi-x86_64.sh)重编 napi so,五件套归位,重装 HAR。
3. ArkTS SessionService:Connect(config)、Write(text)、Resize(cols,rows)、Close();事件用 emitter 或 callback 分发;tag=uniterm.session hilog(connect/write/resize/close/data 计数)。
4. 终端页(TerminalPage.ets,从连接列表点主机进入):
   - 布局:顶部标题(主机名+状态:connecting/connected/disconnected/error)+ 关闭按钮;主体为滚动 Text 流(等宽字体,先把输出按行追加渲染,ANSU 转义先剥掉/或最简解析,光标定位可暂不做——M2 棒2 再精化);
   - 底部输入行:单行输入框+发送(Enter 发送,含\n)——本棒允许"输入框+回车发送"而非全键盘直通,但必须有;
   - resize:页面尺寸变化或初次进入时量测可用列行(按字体宽度估算),Connect 后调 Resize;
   - 断线:事件驱动把状态改 disconnected 并显示原因,UI 不 crash。

本棒验收线(实跑+归档 evidence\M2\):
- 用 web1(10.0.2.2:22,uterm/dev123——把 M1b 的 web1 改成该账号或新建主机)连接 → 终端页出现远端提示符(如 uterm@ubuntu:~$);
- 输入 `echo UT_OK_123` 回车 → 输出流出现 UT_OK_123(截图 + hilog session data 计数);
- 输入 `stty size` → 输出的行列值与页面实际可用区域量测值一致(±1 行/列);
- `exit` 或关页 → closed 事件 + 状态变 disconnected;
- 错密码主机连接 → error 状态 + 可重试(再连正确密码成功);
- 截图≥4(提示符/echo/stty/断线或错密码)、hilog、REPORT-relay1.md、RESUME-STATE.md。

红线:输出必须来自真实 ssh 数据流(hilog data 计数为证);禁止在 UI 假装回显——echo 的 UT_OK 必须是远端 shell 输出;认证失败必须来自 libssh 真实错误。

回复要求:≤18 行:五项验收各一行(✅/❌+关键观测)、napi 新增接口清单一行、修复/踩坑、遗留(给棒2:ANSI 颜色/光标/全键盘直通/性能)。
