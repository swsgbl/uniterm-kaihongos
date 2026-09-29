# 任务书 033:M5 棒5 — 功能深度验收 II(VNC/RDP/AI 侧栏/Telnet)

## 背景
接力 032(本地终端/监控/PG/Redis)。本批靶机由**编排者已在 WSL 架好**(Xvfb+x11vnc、xrdp、telnetd——若编排者通报某项缺装,该按通报为准)。验收铁律同 032:机器证据+可重跑脚本;测不过就修,修不了记 BLOCKED。

## 前置事实(编排者提供,勿重查)
- VM→WSL 走 10.0.2.2;服务必须监听 0.0.0.0 才可达(sshd:2222 已在跑勿动);
- PG 5432/Redis 6379 已由 032 配好(如 032 报告有变更以其为准);
- 建库/状态:credSetup/credUnlock=mp-735;want 通道注入用 /data/local/tmp 文件+$(cat)。

## 四项

### 1. VNC(RFB)
WSL 侧(编排者已装 Xvfb+x11vpc;若未起,你启动):
`Xvfb :1 -screen 0 1280x800x24 & DISPLAY=:1 x11vnc -display :1 -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900 &`,并在 :1 上放个可辨识内容(如 `DISPLAY=:1 xmessage "VNC-PARITY-OK"` 或 xterm)。
UI:新建 VNC 连接 10.0.2.2:5900。判据:连接成功;画面渲染出 :1 的内容(PixelMap 截图含 VNC-PARITY-OK 字样或对应窗口);hilog RFB 握手/帧回调行。

### 2. RDP(FreeRDP 代理链)
WSL 侧 xrdp(编排者已装):`sudo service xrdp start`(3389,0.0.0.0);建测试会话用户可登录(xrdp 默认 Xorg 会话需 Xvfb 支持,headless 可能只到登录画面——**判据放宽**:RDP tab 连上 3389、协议握手成功、渲染出 xrdp 登录界面即 PASS(登录进桌面为加分项,不行如实记录)。
UI:RDP 连接 10.0.2.2:3389。hilog 握手/帧证据+截图。

### 3. AI 侧栏(Anthropic/OpenAI 兼容)
配置:模型服务用 bigmodel(OpenAI 兼容):baseURL `https://open.bigmodel.cn/api/paas/v4/chat/completions`(或应用支持的配置形态,以其 SettingsTab 为准),API key 用编排者在任务书里注入的 `123d2ec1d4814ded9317318f78f4dc6d.fOY4eMcB9MowGw3D`,模型 `glm-5.3`(或 glm-4-flash)。
判据:侧栏发一句「回复 AI-PARITY-OK 六个字符」;收到含 AI-PARITY-OK 的回复(dump/截图);hilog HTTPS 请求行。若应用的 API 形态不兼容 bigmodel,如实记录差异。
**注意:该 key 属用户所有,验证完不必清除(其 VM 自用);REPORT 里不要贴完整 key。**

### 4. Telnet
WSL:`sudo service openbsd-inetd start`(telnetd 经 inetd)或 `telnetd -debug 2323`(直接前台)。防火墙无。
UI:Telnet 连接 10.0.2.2:23(或 2323)。判据:连上出现登录提示(login:);输入用户 uterm/密码后出 shell 提示符(`echo TELNET-PARITY-OK` 屏显);IAC 协商不破坏显示(无乱码);截图。WSL 无 telnetd 可装则此项 BLOCKED 如实记录。

## 产出
`evidence/M5/relay5/`:每项脚本+dump+截图+hilog;REPORT-relay5.md(四项判定表+失败原因)。红线同 032(设备/构建链/断点纪律)。
